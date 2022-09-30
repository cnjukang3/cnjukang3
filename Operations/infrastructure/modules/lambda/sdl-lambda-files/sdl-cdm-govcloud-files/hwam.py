from dateutil.tz import tzutc
from datetime import datetime

keys = ["asset_id_tattoo", "bigfix_asset_id", "bios_guid", "computer_type", "device_type", "environment", "fqdn", "hostname", "InstanceStatus", "ipv4", "ipv6", "last_confirmed_time", "mac", "motherboard_sn", "netbios_hn", "os", "os_version", "os_cpe", "source_tool"]
defaults = {"computer_type": "V","device_type": "server","os_cpe": "SameAsOSVersion","source_tool": "AWS"}

def build_vpcs(vpcs):
    response = {}
    for vpc in vpcs:
        for tag in vpc.get('tags'):
            if tag.get('key') == 'stack':
                response[vpc.get('vpcId')] = tag.get('value')
        if not response.get(vpc.get('vpcId')):
            response[vpc.get('vpcId')] = "~NoData~"
    return response

def get_hostname(hostname, tags):
    if hostname:
        return hostname
    for tag in tags:
        if tag.get('key').lower() == 'name':
            return tag.get('value') if tag.get('value').strip() else "~NoData~"
    return "~NoData~"

def build_ssm_info(instances):
    response = {}
    for instance in instances:
        response[instance.get('resourceId')] = instance.get('configuration').get("AWS:InstanceInformation", {}).get('Content', {}).get(instance.get('resourceId'), {})
    return response

def gather_resources(config_delegate, account):
    instances, vpcs, instance_info = [], [], []
    raw_data = config_delegate.get_query_results("resourceType, resourceId, configuration", f"resourceType IN ('AWS::EC2::Instance', 'AWS::EC2::VPC', 'AWS::SSM::ManagedInstanceInventory') AND accountId = '{account}'")
    for resource in raw_data:
        if resource.get('resourceType') == 'AWS::EC2::Instance':
            instances.append(resource.get('configuration'))
        elif resource.get('resourceType') == 'AWS::EC2::VPC':
            vpcs.append(resource.get('configuration'))
        elif resource.get('resourceType') == 'AWS::SSM::ManagedInstanceInventory':
            instance_info.append(resource)
    return raw_data, instances, build_vpcs(vpcs), build_ssm_info(instance_info)

def process_network_interfaces(networkInterfaces, vpcs):
    response, ipv4 = {}, []
    for netrowkInterface in networkInterfaces:
        if not response.get('environment'):
            response['environment'] = vpcs.get(netrowkInterface.get('vpcId')).lower()
        for ip_address in netrowkInterface.get('privateIpAddresses'):
            if ip_address.get('privateIpAddress') and ip_address.get('privateIpAddress') not in ipv4:
                ipv4.append(ip_address.get('privateIpAddress'))
            if ip_address.get('association', {}).get('publicIp') and ip_address.get('association', {}).get('publicIp') not in ipv4:
                ipv4.append(ip_address.get('association', {}).get('publicIp'))
            if ip_address.get('primary'):
                response['mac'] = netrowkInterface.get('macAddress')
                if netrowkInterface.get('ipv6Addresses'):
                    for ipv6 in netrowkInterface.get('ipv6Addresses'):
                        response['ipv6'] = ipv6.get('privateIpAddress')
    response['ipv4'] = ','.join(ipv4)
    return response

def build_instance(instance, instance_info, vpcs, last_confirmed_time):
    response = {key: "~NoData~" for key in keys}
    response.update({'asset_id_tattoo': instance.get('instanceId'), 'hostname': get_hostname(instance_info.get('ComputerName'), instance.get('tags', [])), 'InstanceStatus': instance.get('state', {}).get('name', "~NoData~"), 'fqdn': instance.get('privateDnsName', "~NoData~"), 'os': instance_info.get('PlatformName', "~NoData~"), 'os_version': instance_info.get('PlatformVersion', "~NoData~"), 'last_confirmed_time': last_confirmed_time, "computer_type": "V","device_type": "server","os_cpe": "SameAsOSVersion","source_tool": "AWS"})
    response.update(process_network_interfaces(instance.get('networkInterfaces'), vpcs))
    return response

def hwam(event, bucket, config_delegate):
    raw, instances, vpcs, ssm = gather_resources(config_delegate, event.get('account'))
    hwam_data = []
    last_confirmed_time = str(datetime.now(tz=tzutc()))
    event.get('overview').update({'instances': len(instances), 'no_ssm': 0})
    for instance in instances:
        ssm_info = ssm.get(instance.get('instanceId'), {})
        if not ssm_info:
            event['overview']['no_ssm'] += 1
        instance = build_instance(instance, ssm_info, vpcs, last_confirmed_time)
        hwam_data.append(instance)
        event.get('hwam').append({key: instance.get(key, "~NoData~") for key in ['fqdn', 'hostname', 'ipv4', 'ipv6', 'mac', 'os', 'asset_id_tattoo']})
    bucket.write_results(hwam_data, event.get('account'), 'hwam')
    bucket.write_results(raw, event.get('account'), 'hwam_raw')
    event.get('phases').append('hwam')
    event['phase'] = 'swam'
    return event
