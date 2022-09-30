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

def build_init(prefix, phases, stage="sdl-aws-feeds", chunk=20):
    response = []
    datacenters = Bucket(BUCKET, prefix, RESULTSPATH).get_object(f"{DATACENTERS}/data_centers.json")
    for datacenter in datacenters:
        config_delegate = config_delegates.get(datacenter)
        if not config_delegate:
            continue
        phases_query = "('" + "', '".join(phases) + "')"
        accounts = [account.get('accountId') for account in ConfigDelegate(config_delegate).get_query_results("accountId, count(*)", f"resourceType IN {phases_query} GROUP BY accountId")]
        #print('Total Account Ids:: ', len(accounts))
        for index in range(0,len(accounts), chunk):
            response.append({'message': {"stage": stage, "prefix": prefix, 'phases': phases, 'accounts': "('" + "', '".join(accounts[index:index+chunk]) + "')", 'datacenter': datacenter}})
    return response

def process_results(event, results):
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
    for account in results:
        #print('ACCOUNT ID From Results:: ', account)
        #print('Results:: ', results)
        #print('Account Data:: ', results[account])
        bucket.write_results(results[account], account, "_".join(event.get('phases')[0].split("::")[0:]))
    event.get('phases').pop(0)
    return {'message': event}

def lambda_handler(event, context):
    event = event.get('message')
    if event.get('stage') == "sdl-daily-aws": #sdl-aws-feeds 
        return build_init(event.get('prefix'), event.get('phases'))
    elif event.get('phases'):
        config_delegate, results = ConfigDelegate(config_delegates.get(event.get('datacenter'))), {}
        response = config_delegate.get_query_results(f"accountId, resourceId, configuration", f"resourceType='{event.get('phases')[0]}' AND accountId IN {event.get('accounts')}")
        print(event.get('phases')[0], len(response))
        #print('Response from query:: ', response)
        for entry in response:
            if entry.get('accountId') not in results:
                results[entry.get('accountId')] = {}
            results[entry.get('accountId')][entry.get('resourceId')] = entry.get('configuration')
        return process_results(event, {account: list(results.get(account).values()) for account in results})
