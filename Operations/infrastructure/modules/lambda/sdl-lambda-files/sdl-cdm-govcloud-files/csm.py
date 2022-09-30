from dateutil.tz import tzutc
from datetime import datetime
import json

def get_severity(severity):
    if severity <= 0:
        return "Informational"
    elif 0 < severity <= 0.3:
        return "Low"
    elif 0.3 < severity <= 0.7:
        return "Moderate"
    elif 0.7 < severity <= 0.8:
        return "Moderate"
    else:
        return "Critical"

def get_bucket(role, account, region_name='us-gov-west-1'):
    try:
        response = role.get_resource('s3', region_name).Bucket(f"cms-cloud-{account}-{region_name}")
        [entry for entry in response.objects.limit(count=1)]
        return response, None
    except Exception as e:
        return None, str(e)

def get_all_objects(bucket, days=180):
    response = []
    for obj in bucket.objects.filter(Prefix='InspecResults/'):
        if (datetime.now(tz=tzutc()) - obj.last_modified).days <= days:
            results = json.loads(obj.get().get('Body').read().decode('utf-8'))
            if results:
                response.append({'last_seen': str(obj.last_modified), 'prefix': obj.last_modified.strftime("year=%Y/month=%m/day=%d"), 'asset_id_tattoo': obj.key.split("_")[0].split("InspecResults/")[-1], 'results': results})
    return response

def get_instance_findings(profile, response={}):
    for control in profile.get('controls'):
        failed = False
        for result in control.get('results'):
            if 'FAILED' in result.get('status').upper():
                failed = True
        if failed and control.get('id') not in response:
            response[control.get('id')] = get_severity(control.get('impact', 0.0))
    return response

def set_passthrough(instance_id, fisma_system, hwam, last_seen):
    instance = {}
    for asset in hwam:
        if instance_id == asset.get('asset_id_tattoo'):
            instance = asset
            break
    return {
        'CDM': {
            'HWAM': {
                'Asset_ID_Tattoo': instance_id,
                'Data_Center_ID': fisma_system.get('Data Center'),
                'FQDN': instance.get('fqdn'),
                'Hostname': instance.get('hostname'),
                'ipv4': instance.get('ipv4'),
                'ipv6': instance.get('ipv6'),
                'mac': instance.get('mac'),
                'os': instance.get('os'),
                'FISMA_ID': fisma_system.get('UID')
            },
            'CSM': {
                "Server_Type": "member server",
                "source_tool": "Inspec",
                "last_seen": last_seen
            }
        }
    }

def process_results(event, instances, fisma_system):
    results = []
    for instance in instances:
        instance['results']['passthrough'] = set_passthrough(instance.get('asset_id_tattoo'), fisma_system, event.get('hwam'), instance.get('last_seen'))
        results.append(instance.get('results'))
        response = {}
        for profile in instance.get('results').get('profiles'):
            get_instance_findings(profile, response)
        for finding in response:
            if response.get(finding) not in event.get('overview').get('findings'):
                event['overview']['findings'][response.get(finding)] = 0
            event['overview']['findings'][response.get(finding)] += 1
    return results

def csm(event, bucket, role, region_name='us-gov-west-1'):
    if role:
        if event.get('hwam'):
            account_bucket, error = get_bucket(role, event.get('account'), region_name)
            if error:
                event.get('errors').append(f"{event.get('account')} - csm - {error}")
                event['phase'] = 'vuln'
                del event['hwam']
                print(event)
                return event
            elif account_bucket:
                event['overview']['findings'] = {}
                results = get_all_objects(account_bucket)
                if results:
                    response = process_results(event, results, bucket.get_fisma_system(event.get('account')))
                    #print(f"csm:: {response}")
                    bucket.write_results(response, event.get('account'), 'csm')
        event.get('phases').append('csm')
    del event['hwam']
    event['phase'] = 'vuln'
    print(event)
    return event
