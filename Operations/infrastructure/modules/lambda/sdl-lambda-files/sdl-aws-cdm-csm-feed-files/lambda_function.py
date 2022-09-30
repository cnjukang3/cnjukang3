from common import ConfigDelegate, Bucket, AssumeRole
# from config_delegate_service import ConfigDelegate
# #from secret_manager_service import SecretManager
# from role_service import AssumeRole, get_secret
from importlib import import_module
from datetime import datetime
import boto3
import json
import uuid
import os

config_delegates = {"AWS GovCloud": 'CONFIGDELEGATEGOVCLOUD', "AWS": 'CONFIGDELEGATE'}

GOVCLOUDROLE = os.getenv('GOVCLOUDROLE')


def build_init(prefix, phases, stage="sdl-aws-cdm-csm-feed"):
    # get all the account ids from config delegates associated with EC2 Instances
    response = []
    for datacenter in config_delegates:
        config_delegate = config_delegates.get(datacenter)
        accounts = [account.get('accountId') for account in ConfigDelegate(config_delegate).get_query_results("accountId, count(*)", f"resourceType = 'AWS::EC2::Instance' GROUP BY accountId")]
        # all_accounts = [account.get('accountId') for account in ConfigDelegate(config_delegate).get_query_results("accountId, count(*)", f"resourceType != 'JUNK887' GROUP BY accountId")]
        # print("len accounts:  ",len(accounts))
        # print("len all_accounts:  ",len(all_accounts))
        response += [{"message": {"stage": stage, "prefix": prefix, 'phases': phases, 'account': account, 'hwam': [], 'datacenter': datacenter}} for account in accounts]
    return response
'''
This returns csm methods from csm.py
respectively
'''
def get_method(phase):
    library_object = import_module(phase)
    return getattr(library_object, phase)

def start_phase(event):
    phase = event.get("phases").pop(0)
    config = json.load(open('config.json', 'r'))
    datacenter = config.get('datacenters').get(event.get('datacenter'))
    bucket = Bucket(event.get('prefix'), **datacenter)

    method = get_method(phase)
    if config.get('role'):
        role = None
        try:
            role = AssumeRole(event.get('account'), service_account=datacenter.get('config_secret'), **config.get('role'))
        except Exception as e:
            print(f"{event.get('errors')} - {event.get('account')} - {phase} - {str(e)}")
            #event.get('errors').append(f"{event.get('account')} - {phase} - {str(e)}")
        return method(event, bucket, role)
    raise Exception(f"Invalid Phase: {phase} - for Account: {event.get('account')} - Role: {event.get('role')} - Config Delegate: {event.get('config_delegate')}")

def lambda_handler(event, context):
    event = event.get('message')
    if event.get('stage') == 'sdl-daily-aws-vcc': # sdl-daily-aws-vcc is the name of the step function that calls this lambda
        return build_init(event.get('prefix'), event.get('phases'))
    elif event.get('phases'):
         return {'message': start_phase(event)}


