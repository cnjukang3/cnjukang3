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

PHASES = ["AWS::IAM::Group", "AWS::IAM::Policy", "AWS::IAM::Role", "AWS::IAM::User", 'complete']


# def build_init(prefix, stage="sdl-aws-iam-feed", chunk=10):
#     response = []
#     datacenters = json.load(open('data_centers.json', 'r')).get('datacenters')
#     print(datacenters)
#     for datacenter in datacenters:
#         response.append({'message': {"stage": stage, "prefix": prefix, 'phase': PHASES[0],
#                                      'account': account, 'config_delegate': True, 'datacenter': datacenter} for account in ConfigDelegate(datacenters.get(datacenter).get('config_secret')).gather_accounts()})
#     print(response)
#     return response

def build_init(prefix, stage="sdl-aws-iam-feed", chunk=10):
    response = []
    datacenters = Bucket(BUCKET, prefix, RESULTSPATH).get_object(f"{DATACENTERS}/data_centers.json")
    print(datacenters)
    for datacenter in datacenters:
        config_delegate = config_delegates.get(datacenter)
        if not config_delegate:
            continue
        config_accounts = ConfigDelegate(config_delegate).gather_accounts()
        print("Config of ACCOUNT: ", config_accounts)
        print("C of ACCOUNT: ", chunk)
        for index in range(0,len(config_accounts), chunk):
            response.append({'message': {"stage": stage, "prefix": prefix, 'phase': PHASES[0], 'accounts': "('" + "', '".join(config_accounts[index:index+chunk]) + "')", 'datacenter': datacenter}})
    print('Response from buid init:: ', response) # added to check the code
    return response

# def process_results(event, results):
#     #datacenters = json.load(open('data_centers.json', 'r')).get('datacenters') # added to check the code
#     #bucket = Bucket(BUCKET, event.get('prefix'), **datacenters) # added to check the code
#     bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
#     bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
#     print('Result::: ', results)
#     print('Result::: ', event.get('account'))
#     bucket.write_results(results, event.get('account'), "_".join(event.get('phase').split("::")[0:]))
#     index = PHASES.index(event.get('phase'))
#     event['phase'] = PHASES[index+1]
#     print('message in process result::: ', event) # added to check the code
#     return {'message': event}

def process_results(event, results):
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
    for account in results:
        print('account::: ', account) # added to check the code
        print('Results::: ', results)
        bucket.write_results(results, account, "_".join(event.get('phases')[0].split("::")[0:]))
    event.get('phases').pop(0)
    return {'message': event}

def lambda_handler(event, context):
    event = event.get('message')
    if event.get('phase') == 'sdl-aws-iam-feed': #
        return build_init(event.get('prefix'))
    elif event.get('phase') in ["AWS::IAM::Group", "AWS::IAM::Policy", "AWS::IAM::Role", "AWS::IAM::User"]:
        config_delegate, results = ConfigDelegate(config_delegates.get(event.get('datacenter'))), {}
        response = config_delegate.get_query_results(f"accountId, resourceId, configuration", f"resourceType='{event.get('phase')}' AND accountId IN {event.get('accounts')}")
        print(len('LENGTH:: ',response))
        print('RESPONSE::: ', response) # added to check the code
        for entry in response:
            print(entry.get('accountId')) # added to check the code
            if entry.get('accountId') not in results:
                results[entry.get('accountId')] = {}
            results[entry.get('accountId')][entry.get('resourceId')] = entry.get('configuration')
        return process_results(event, {account: list(results.get(account).values()) for account in results})
