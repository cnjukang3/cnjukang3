from common import ConfigDelegate, Bucket, AssumeRole, get_secret
from importlib import import_module
from datetime import datetime
import boto3
import json
import uuid
import os

config_delegates = {"AWS GovCloud": 'CONFIGDELEGATEGOVCLOUD', "AWS": 'CONFIGDELEGATE'}
BUCKET = os.getenv('BUCKET')
RESULTSPATH = os.getenv('BUCKETPATH')
DATACENTERS = os.getenv('DATACENTERS')
GOVCLOUDROLE = os.getenv('GOVCLOUDROLE')

def build_init(prefix, phases, stage="sdl-aws-cdm-feed"):
    # get all the account ids from config delegates associated with EC2 Instances
    response = []
    for datacenter in config_delegates:
        config_delegate = config_delegates.get(datacenter)
        accounts = [account.get('accountId') for account in ConfigDelegate(config_delegate).get_query_results("accountId, count(*)", f"resourceType = 'AWS::EC2::Instance' GROUP BY accountId")]
        response += [{"message": {"stage": stage, "prefix": prefix, 'phases': phases, 'account': account, 'hwam': [], 'datacenter': datacenter}} for account in accounts]
    return response
'''
This returns config_data, vuln, csm methods from config_data.py, vuln.py and csm.py
respectively
'''
def get_method(phase):
    library_object = import_module(phase)
    return getattr(library_object, phase)

def start_phase(event):
    phase = event.get('phases').pop(0)
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
    # get the config_data, vuln and csm phase method
    method = get_method(phase)
    # if phases is not in vuln, csm, and config_data, then the step function  has reach the final phase (complete)
    if not phase in ['config_data', 'vuln', 'csm']:
        event['phases'] = ['complete']
        return event
    elif phase in ['vuln', 'csm']:
        role = None
        try: # this will allow vuln and csm to assume the role for Config Delegate (AWS Commercial)
            role = AssumeRole(event.get('account'), service_account=config_delegates.get(event.get('datacenter')), **get_secret(GOVCLOUDROLE))
        except Exception as e:
            print(f"{event.get('errors')} - {event.get('account')} - {phase} - {str(e)}")
            #event.get('errors').append(f"{event.get('account')} - {phase} - {str(e)}")
        return method(event, bucket, role)
    elif phase in ['config_data']:
        return method(event, bucket, ConfigDelegate(config_delegates.get(event.get('datacenter'))))
    raise Exception(f"Invalid Phase: {phase} - for Account: {event.get('account')} - Role: {event.get('role')} - Config Delegate: {event.get('config_delegate')}")

def lambda_handler(event, context):
    event = event.get('message')
    if event.get('stage') == 'sdl-daily-aws': # sdl-daily-aws is the name of the step function that calls this lambda
        return build_init(event.get('prefix'), event.get('phases'))
    elif event.get('phases'):
        return {'message': start_phase(event)}
