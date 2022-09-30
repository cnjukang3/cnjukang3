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

PHASES = ["AWS::ElasticLoadBalancing::LoadBalancer", "AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::EC2::Subnet", "AWS::EC2::SecurityGroup", "AWS::EC2::NetworkInterface", 'complete']

def build_init(prefix, stage="sdl-aws-networking-feed", chunk=10):
    response = []
    datacenters = Bucket(BUCKET, prefix, RESULTSPATH).get_object(f"{DATACENTERS}/data_centers.json")
    for datacenter in datacenters:
        config_delegate = config_delegates.get(datacenter)
        if not config_delegate:
            continue
        config_accounts = ConfigDelegate(config_delegate).gather_accounts()
        for index in range(0,len(config_accounts), chunk):
            response.append({'message': {"stage": stage, "prefix": prefix, 'phase': PHASES[0], 'accounts': "('" + "', '".join(config_accounts[index:index+chunk]) + "')", 'datacenter': datacenter}})
    return response

def process_results(event, results):
    bucket = Bucket(BUCKET, event.get('prefix'), RESULTSPATH)
    bucket.build_datacenter(event.get('datacenter'), f"{DATACENTERS}/data_centers.json")
    for account in results:
        bucket.write_results(results, account, "_".join(event.get('phase').split("::")[0:]))
    index = PHASES.index(event.get('phase'))
    event['phase'] = PHASES[index+1]
    return {'message': event}

def lambda_handler(event, context):
    event = event.get('message')
    if event.get('phase') == 'sdl-aws-networking-feed':
        return build_init(event.get('prefix'))
    elif event.get('phase') in ["AWS::ElasticLoadBalancing::LoadBalancer", "AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::EC2::Subnet", "AWS::EC2::SecurityGroup", "AWS::EC2::NetworkInterface"]:
        config_delegate, results = ConfigDelegate(config_delegates.get(event.get('datacenter'))), {}
        for entry in config_delegate.get_query_results(f"accountId, resourceId, configuration", f"resourceType='{event.get('phase')}' AND accountId IN {event.get('accounts')}"):
            if entry.get('accountId') not in results:
                results[entry.get('accountId')] = {}
            results[entry.get('accountId')][entry.get('resourceId')] = entry.get('configuration')
        return process_results(event, {account: list(results.get(account).values()) for account in results})
