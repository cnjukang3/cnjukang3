from datetime import datetime, timedelta
import requests
import urllib3
import json

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def generate_passthrough(phase, fisma_system, instance, instance_uuid, os_version):
    response = {
        "CDM": {
            "HWAM": {
                "Asset_ID_Tattoo": instance.get('instanceId'),
                "Data_Center_ID": fisma_system.get("Data Center"),
                "FQDN": instance.get("local-hostname"),
                "Hostname": instance.get('hostname'),
                "ipv4": instance.get("local-ipv4"),
                "ipv6": None,
                "mac": instance.get("mac"),
                "os": os_version,
                "FISMA_ID": fisma_system.get("UID")
            }
        }
    }
    if phase == 'csm':
        response["CDM"]["CSM"] = {"Server_Type": "member server","source_tool": "Security Center","last_seen": instance.get('pendingTime')}
    elif phase == 'vuln':
        response["CDM"]["VULN"] = {"TenableUUID":instance_uuid,"source_tool": "Security Center","last_seen": instance.get('pendingTime')}
    return response

def write_results(instances, phase, bucket):
    response = {}
    for instance in instances:
        if instance.get('instance').get('accountId') not in response:
            response[instance.get('instance').get('accountId')] = {}
        response[instance.get('instance').get('accountId')][instance.get('instance').get('instanceId')] = instance
    for account in response:
        for instance in response.get(account):
            if response.get(account).get(instance).get(phase):
                bucket.write_results(response.get(account).get(instance), account, f"{instance}/{phase}")

def build_results(instances, findings, phase, bucket):
    response, accounts = {}, {}
    for instance_uuid in instances:
        instance = instances.get(instance_uuid).get('instance')
        if not instance:
            continue
        if instance.get('accountId') not in accounts:
            accounts[instance.get('accountId')] = bucket.get_fisma_system(instance.get('accountId'))
        fisma_system = accounts.get(instance.get('accountId'))
        response[instance_uuid] = {**instances.get(instance_uuid), 'passthrough': generate_passthrough(phase, fisma_system, instance, instance_uuid, instances.get(instance_uuid).get('os'))}
    for finding in findings:
        if finding.get('uuid') not in response:
            continue
        elif phase not in response.get(finding.get('uuid')):
            response[finding.get('uuid')][phase] = []
        response.get(finding.get('uuid')).get(phase).append(finding)
    write_results(list(response.values()), phase, bucket)

def security_center_authenticate(host, username, password):
    response = requests.post(f"https://{host}/rest/token", json={'username': username, 'password': password}, verify=False)
    if response.status_code == 200:
        token = str(response.json().get('response', {}).get('token'))
        cookie = response.headers.get('Set-Cookie', "").split("TNS_SESSIONID=")[-1].split(';')[0]
        print("TOKEN:: ", token)
        print("COOKIE:: ", cookie)
        return {'host': host, 'token': token, 'cookie': cookie}
    return {'host': None, 'token': None, 'cookie': None}

def build_filter(last_seen, tool, start_offset=0, end_offset=50000, filters=[]):
    response = {"query": {"type": "vuln","tool": tool,"sourceType": "cumulative","startOffset": start_offset,"endOffset": end_offset,"filters": [{"filterName": "lastSeen","operator": "=","value": last_seen}]},"sourceType": "cumulative", "type": "vuln"}
    for filter in filters:
        if filter:
            response.get("query").get('filters').append({"filterName": filter[0],"operator": filter[1],"value": filter[2]})
    return response

def get_analysis(query, host, token, cookie):
    results = []
    while True:
        response = requests.post(f"https://{host}/rest/analysis", json=query, headers={"X-SecurityCenter": token}, cookies={'TNS_SESSIONID': cookie}, verify=False)
        if response.status_code == 200:
            response = response.json().get('response')
            results += response.get('results')
            if len(results) < int(response.get('totalRecords')):
                query['query']['startOffset'] = query['query']['endOffset']
                query['query']['endOffset'] += 50000
                continue
            else:
                return results
        else:
            return results

def make_request(host, endpoint, token, cookie):
    response = requests.get(f"https://{host}/rest/{endpoint}", headers={"X-SecurityCenter": token}, cookies={'TNS_SESSIONID': cookie}, verify=False)
    if response.status_code == 200:
        return response.json().get('response').get('usable')
    return []

def process_aws_plugin(instance):
    response = {}
    for index in instance.get('pluginText').split("\n\n")[1].split("\n"):
        key = index.split(": ")[0].replace(" - ", "").strip()
        if key in ['billingProducts', 'devpayProductCodes', 'marketplaceProductCodes']:
            continue
        elif len(index.split(": ")) <= 1:
            continue
        response[key] = index.split(": ")[1].strip()
    return response

def process_os_plugin(finding):
    gold_image = finding.get('pluginText').split("\n\n")[-1].split("<")[0]
    if gold_image and "Yum Updates" in gold_image:
        gold_image = gold_image.split("\n")[0].split("#")[-1]
    return gold_image

def process_instances(findings):
    response = {}
    for finding in findings:
        if not finding.get('uuid'):
            continue
        elif finding.get('uuid') not in response:
            response[finding.get('uuid')] = {}
        if finding.get('pluginID') in ["90191","90427"]:
            response[finding.get('uuid')]['instance'] = process_aws_plugin(finding)
        elif finding.get('pluginID') in ["20811","22869"]:
            response[finding.get('uuid')]['swam'] = finding
        elif finding.get('pluginID') in ["1006922","1030414","11936"]:
            response[finding.get('uuid')]['os'] = process_os_plugin(finding)
    return response

def process_phase(phase, bucket, securitycenter, instances=[], days=1, chunck_size=20):
    result = {}
    timestamp = f"{(datetime.now() - timedelta(days=days)).strftime('%s')}-{datetime.now().strftime('%s')}"
    print("PHASE: ", phase)
    if phase == 'swam':
        securitycenter = security_center_authenticate(**securitycenter)
        print("SECURITY CENTER:: ", securitycenter)
    if not securitycenter.get('cookie') or not securitycenter.get('token'):
        raise Exception('Error: Unable to Authenticate with Security Center.')
    instances = process_instances(get_analysis(build_filter(timestamp, 'vulndetails', filters=[('pluginID', '=',"90191,90427,1006922,1030414,11936")] + [('uuid', '=', uuid) for uuid in instances]), **securitycenter))
    if phase == 'csm':
        results = get_analysis(build_filter(timestamp, 'vulndetails', filters=[('pluginID', '!=',"20811,22869,90191,90427,1006922,1030414,11936"), ('repositoryIDs', '=', '2')] + [('uuid', '=', uuid) for uuid in instances]), **securitycenter)
    elif phase == 'vuln':
        results = get_analysis(build_filter(timestamp, 'vulndetails', filters=[('pluginID', '!=',"20811,22869,90191,90427,1006922,1030414,11936"), ('repositoryIDs', '=', '1')] + [('uuid', '=', uuid) for uuid in instances]), **securitycenter)
    elif phase == 'swam':
        results = get_analysis(build_filter(timestamp, 'vulndetails', filters=[('pluginID', '=',"20811,22869")] + [('uuid', '=', uuid) for uuid in instances]), **securitycenter)
    build_results(instances, results, phase, bucket)
    return list(instances.keys()), securitycenter
