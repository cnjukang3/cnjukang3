from securitycenter import Bucket, process_phase
import json
import os

SECURITYCENTER = os.getenv('SECURITYCENTER')

def build_swam_response(event, phase, instances, chunck_size=200):
    event['phase'] = phase
    response = []
    for index in range(0, len(instances), chunck_size):
        response.append({**event, 'instances': instances[index:index+chunck_size]})
        print(f"Response:: {response} for {phase}")
    return response

def lambda_handler(event, context):
    if event.get('phase') in ['swam', 'csm', 'vuln']:
        datacenter = json.load(open('data_centers.json', 'r')).get(event.get('datacenter'))
        bucket = Bucket(event.get('prefix'), **datacenter)
        instances = process_phase(event.get('phase'), SECURITYCENTER, bucket, event.get('instances', []))
        if event.get('phase') == 'swam':
            return build_swam_response(event, 'csm', instances)
        elif event.get('phase') == 'csm':
            event['phase'] = 'vuln'
            return event
        else:
            return {'phase': 'complete'}
