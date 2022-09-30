from common import ConfigDelegate, Bucket, AssumeRole
from importlib import import_module
from datetime import datetime
import boto3
import json
import uuid
import os

SDLMACHINE = os.getenv('SDLMACHINE')

def init_central(step_function):
    client = boto3.client('stepfunctions')
    response = client.start_execution(
        stateMachineArn=step_function,
        name=f"sdl-govcloud-cdm-{datetime.now().strftime('%Y-%m-%d')}-{uuid.uuid4()}",
        input=json.dumps({'prefix': datetime.now().strftime('year=%Y/month=%m/day=%d'), "phase": "sdl-cdm-init"})
    )

def build_init(prefix):
    response = []
    datacenters = json.load(open('config.json', 'r')).get('datacenters')
    for datacenter in datacenters:
        response += [{"prefix": prefix, 'phase': 'config_data', 'phases': [], 'errors': [], 'account': account, 'overview': {}, 'hwam': [], 'config_delegate': True, 'datacenter': datacenter} for account in ConfigDelegate(datacenters.get(datacenter).get('config_secret')).gather_accounts()]
    return response

def get_method(phase):
    library_object = import_module(phase)
    return getattr(library_object, phase)


def start_phase(event):
    config = json.load(open('config.json', 'r'))
    datacenter = config.get('datacenters').get(event.get('datacenter'))
    bucket = Bucket(event.get('prefix'), **datacenter)

    method = get_method(event.get('phase'))
    print(f"Phase:: {event.get('phase')}")
    if event.get('role'):
        role = None
        try:
            role = AssumeRole(event.get('account'), service_account=datacenter.get('config_secret'), **config.get('role'))
        except Exception as e:
            event.get('errors').append(f"{event.get('account')} - {event.get('phase')} - {str(e)}")
        return method(event, bucket, role)
    elif event.get('config_delegate'):
        return method(event, bucket, ConfigDelegate(datacenter.get('config_secret')))
    raise Exception(f"Invalid Phase: {event.get('phase')} - for Account: {event.get('account')} - Role: {event.get('role')} - Config Delegate: {event.get('config_delegate')}")

def lambda_handler(event, context):
    if event.get('source') == 'aws.events':
        init_central(SDLMACHINE)
    elif event.get('phase') == 'sdl-cdm-init':
        return build_init(event.get('prefix'))
    elif event.get('phase') == 'sdl-cdm-govcloud-post-process':
        return event.get('accounts')
    elif event.get('phase') in ['config_data', 'vuln', 'csm']:
        return start_phase(event)
