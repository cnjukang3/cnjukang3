from common import Bucket, get_secret
from securitycenter import process_phase
import json
import uuid
import os

SECURITYCENTER = os.getenv('SECURITYCENTER')
BUCKET = os.getenv('BUCKET')
RESULTSPATH = os.getenv('BUCKETPATH')
DATACENTERS = os.getenv('DATACENTERS')

PHASES = ['swam', 'csm', 'vuln', 'complete']

def build_swam_response(bucket, event, phase, instances, path, securitycenter, chunck_size=200):
    event['phase'] = phase
    response = []
    for index in range(0, len(instances), chunck_size):
        key = f"{path}/securitycenter/{str(uuid.uuid4())}"
        bucket.put_object(key, json.dumps({'instances': instances[index:index+chunck_size], 'securitycenter': securitycenter}, indent=4))
        response.append({**event, 'key': key})
        print('RESPONSE:: ',response)
    return response

def post_processing(event, bucket, results, path, securitycenter):
    index = PHASES.index(event.get('phase'))
    event['phase'] = PHASES[index+1]
    if index == 0:
        return build_swam_response(bucket, event, PHASES[index+1], results, path, securitycenter, 100)
    elif index + 1 == 3:
        bucket.delete_object(event.get('key'))
    return event

def lambda_handler(event, context):
    event = event.get('message') if event.get('message') else event
    if event.get('phase') in PHASES:
        bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
        bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
        if event.get('phase') == 'swam':
            entry = {'securitycenter': get_secret(SECURITYCENTER), 'instances': []}
        else:
            entry = bucket.get_object(event.get('key'))
        instances, securitycenter = process_phase(event.get('phase'), bucket, **entry)
        return post_processing(event, bucket, instances, DATACENTERS, securitycenter)
