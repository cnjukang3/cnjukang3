from dateutil.tz import tzutc
from datetime import datetime, timedelta

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
    for finding in response:
        if 'findings' not in event.get('overview'):
            event['overview']['findings'] = {}
        if finding.get('severity') not in event.get('overview').get('findings'):
            event['overview']['findings'][finding.get('severity')] = 0
        event['overview']['findings'][finding.get('severity')] += 1
    return response

def vuln(event, bucket, role):
    if role:
        if event.get('overview').get('instances'):
            response = get_findings(event, role)
            if response:
                
                bucket.write_results(response, event.get('account'), 'vuln')
        event.get('phases').append('vuln')
    event['phase'] = 'complete'
    return event