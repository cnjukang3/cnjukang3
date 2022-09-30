import os
from storage_service import Bucket
from sdl_path_service import SdlPathService
from config_delegate_service import ConfigDelegate
from dateutil.tz import tzutc
from datetime import datetime
import urllib.request

keys = ["fqdn", "hostname", "ipv4", "ipv6", "mac", "os", "asset_id_tattoo"]

BUCKET = os.getenv("BUCKET")
RESULTSPATH = os.getenv("BUCKETPATH")
DATACENTERS = os.getenv("DATACENTERS")
GOVCLOUDROLE = os.getenv("GOVCLOUDROLE")

# get the slack chennel url and id
SLACK_URL = os.getenv('SLACK_URL')
CHANNEL_ID = os.getenv('CHANNEL_ID')


# get the vpcs id
def build_vpcs(vpcs):
    response = {}
    for vpc in vpcs:
        for tag in vpc.get("tags"):
            if tag.get("key") == "stack":
                response[vpc.get("vpcId")] = tag.get("value")
        if not response.get(vpc.get("vpcId")):
            response[vpc.get("vpcId")] = None
    return response


# get the hostname
def get_hostname(hostname, tags):
    if hostname:
        return hostname
    for tag in tags:
        if tag.get("key").lower() == "name":
            return tag.get("value")
    return None


# build the ssm information
def build_ssm_info(instances):
    response = {}
    for instance in instances:
        response[instance.get("resourceId")] = (
            instance.get("configuration")
            .get("AWS:InstanceInformation", {})
            .get("Content", {})
            .get(instance.get("resourceId"), {})
        )
    return response


# gather the EC2 configuration, VPC and SSM
def gather_resources(config_delegate, account):
    instances, vpcs, instance_info = [], [], []
    raw_data = config_delegate.get_query_results(
        "resourceType, resourceId, configuration",
        f"resourceType IN ('AWS::EC2::Instance', 'AWS::EC2::VPC', 'AWS::SSM::ManagedInstanceInventory') AND accountId = '{account}'",
    )
    for resource in raw_data:
        if resource.get("resourceType") == "AWS::EC2::Instance":
            instances.append(resource.get("configuration"))
        elif resource.get("resourceType") == "AWS::EC2::VPC":
            vpcs.append(resource.get("configuration"))
        elif resource.get("resourceType") == "AWS::SSM::ManagedInstanceInventory":
            instance_info.append(resource)
    return raw_data, instances, build_vpcs(vpcs), build_ssm_info(instance_info)


# gather the networking interfaces, public and private IP adresses with subnets association
def process_network_interfaces(networkInterfaces, vpcs):
    response, ipv4 = {"environment": None, "ipv4": [], "ipv6": [], "mac": []}, []
    for netrowkInterface in networkInterfaces:
        if not response.get("environment"):
            response["environment"] = vpcs.get(netrowkInterface.get("vpcId")).lower()
        for ip_address in netrowkInterface.get("privateIpAddresses"):
            if ip_address.get("privateIpAddress") and ip_address.get(
                "privateIpAddress"
            ) not in response.get("ipv4"):
                response.get("ipv4").append(ip_address.get("privateIpAddress"))
            if ip_address.get("macAddress") and ip_address.get(
                "macAddress"
            ) not in response.get("mac"):
                response.get("ipv4").append(ip_address.get("macAddress"))
            if ip_address.get("association", {}).get("publicIp") and ip_address.get(
                "association", {}
            ).get("publicIp") not in response.get("ipv4"):
                response.get("ipv4").append(
                    ip_address.get("association", {}).get("publicIp")
                )
            if netrowkInterface.get("ipv6Addresses"):
                for ipv6 in netrowkInterface.get("ipv6Addresses"):
                    response["ipv6"] = ipv6.get("privateIpAddress")
    return response


# build the instance using instance info and vpcs
def build_instance(instance, instance_info, vpcs):
    response = {key: None for key in keys}
    response.update(
        {
            "asset_id_tattoo": instance.get("instanceId"),
            "hostname": get_hostname(
                instance_info.get("ComputerName"), instance.get("tags", [])
            ),
            "fqdn": instance.get("privateDnsName"),
            "os": instance_info.get("PlatformName"),
        }
    )
    response.update(process_network_interfaces(instance.get("networkInterfaces"), vpcs))
    return response


# get config data for each account id and write it to S3 bucket
def config_data(event, config_delegate):
    global status
    # get the s3 bucket name, prefix and path
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    # get the datacenters from s3
    # datacenters = bucket.get_object(f"{DATACENTERS}/data_centers.json")
    datacenters = bucket.get_object(f"{DATACENTERS}/fisma.json")
    # get the s3 prefix and path to build the fisma key
    sdl_path_service = SdlPathService(None, None, event.get('prefix'), RESULTSPATH)
    # get the fisma systems from the datacenter json file
    sdl_path_service.build_datacenter(event.get('datacenter'), datacenters)
   
    last_confirmed_time = int(datetime.now(tz=tzutc()).timestamp())
    raw, instances, vpcs, ssm = gather_resources(config_delegate, event.get("account"))
    status = False
    if instances:
        event["instances"] = True
    for instance in instances:
        instance["last_confirmed_time"] = last_confirmed_time
        ssm_info = ssm.get(instance.get("instanceId"), {})
        if event.get("datacenter") == "AWS GovCloud":
            instance = build_instance(instance, ssm_info, vpcs)
            event.get("hwam").append(instance)
        else:
            event["phases"] = ["complete"]
    
    if len(raw) > 0:
        status = True

    # build the fisma key for S3
    key = sdl_path_service.build_key(event.get('account'), 'config_data')
    bucket.write_results(raw, key)
    return event
