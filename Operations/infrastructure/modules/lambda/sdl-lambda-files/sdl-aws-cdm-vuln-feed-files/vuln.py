import os
from storage_service import Bucket
from sdl_path_service import SdlPathService
from config_delegate_service import ConfigDelegate
from dateutil.tz import tzutc
from datetime import datetime, timedelta

BUCKET = os.getenv("BUCKET")
RESULTSPATH = os.getenv("BUCKETPATH")
DATACENTERS = os.getenv("DATACENTERS")
GOVCLOUDROLE = os.getenv("GOVCLOUDROLE")

def clean_finding(finding):
    for key in finding:
        if type(finding.get(key)) == datetime:
            finding[key] = str(finding.get(key))
    return finding

def describe_findings(client, findingArns):
    response = []
    for finding in client.describe_findings(findingArns=findingArns, locale='EN_US').get('findings'):
        response.append(clean_finding(finding))
    return response

def list_findings(client, days=180):
    response, nextToken = [], None
    beginDate, endDate = datetime.now(tz=tzutc()) - timedelta(days=days), datetime.now(tz=tzutc())
    while True:
        if nextToken:
            results = client.list_findings(filter={'creationTimeRange': {'beginDate': beginDate,'endDate': endDate}, 'severities': ['Low','Medium','High','Informational']}, maxResults=100, nextToken=nextToken)
        else:
            results = client.list_findings(filter={'creationTimeRange': {'beginDate': beginDate,'endDate': endDate},'severities': ['Low','Medium','High','Informational']}, maxResults=100)
        if results.get('findingArns'):
            response += describe_findings(client, results.get('findingArns'))
        if results.get('nextToken'):
            nextToken = results.get('nextToken')
        else:
            return response

def get_findings(event, role, region='us-gov-west-1'):
    client = role.get_client('inspector', region)
    response = list_findings(client)
    return response

def vuln(event, role):
    # get the s3 bucket name, prefix and path
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    # get the datacenters from s3
    # datacenters = bucket.get_object(f"{DATACENTERS}/data_centers.json")
    datacenters = bucket.get_object(f"{DATACENTERS}/fisma.json")
    # get the s3 prefix and path to build the fisma key
    sdl_path_service = SdlPathService(None, None, event.get('prefix'), RESULTSPATH)
    # get the fisma systems from the datacenter json file
    sdl_path_service.build_datacenter(event.get('datacenter'), datacenters)
    if role:
        response = get_findings(event, role)
        if response:
            key = sdl_path_service.build_key(event.get('account'), 'vuln')
            bucket.write_results(response, key)
    return event
