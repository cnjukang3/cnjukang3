from botocore.config import Config
from datetime import datetime
import boto3
import json
import os

config_delegates = {"AWS GovCloud": 'CONFIGDELEGATEGOVCLOUD', "AWS": 'CONFIGDELEGATE'}
bucket = os.getenv('BUCKET')
path = os.getenv('BUCKETPATH')

def extract_accounts_data():
    accounts_data = []
    for datacenter in config_delegates:
        config_delegate = config_delegates.get(datacenter)
        secretName=os.getenv(config_delegate)
        secret_value = json.loads(boto3.client("secretsmanager").get_secret_value(SecretId=secretName).get("SecretString"))
        aggregator = secret_value.get('aggregator')
        region = secret_value.get('region')
        if datacenter=="AWS GovCloud":
            access_keys = {'AccessKeyId': secret_value.get("access_key_id"), 'SecretAccessKey': secret_value.get("secret_access_key")}
        else:
            access_keys = boto3.client('sts').assume_role(RoleArn=secret_value.get("role"), ExternalId=secret_value.get("external_id"), RoleSessionName='cms-cloud-dragnet-infrastructure').get('Credentials')
        client=boto3.client(
            'config',
            aws_access_key_id=access_keys.get('AccessKeyId'),
            aws_secret_access_key=access_keys.get('SecretAccessKey'),
            aws_session_token=access_keys.get('SessionToken'),
            region_name=region,
            config=Config(retries = {'max_attempts': 15})
        )
        query = "SELECT accountId, count(*) GROUP BY accountId"
        results,token = [], None
        while True:
            if token:
                response = client.select_aggregate_resource_config(Expression=query, ConfigurationAggregatorName=aggregator, MaxResults=100, NextToken=token)
            else:
                response = client.select_aggregate_resource_config(Expression=query, ConfigurationAggregatorName=aggregator, MaxResults=100)
            results +=  [json.loads(account).get('accountId') for account in response.get('Results', [])]
            if response.get('NextToken'):
                token = response.get('NextToken')
            else:
                break
        accounts_data+=[{datacenter:results}]
    return accounts_data
    
def upload_file(file,key):
    client=boto3.client('s3')
    client.put_object(Body=file, Bucket=bucket, Key=key,ContentType='application/json')
    
def lambda_handler(event, context):
    file=json.dumps(extract_accounts_data())
    key=f"{path}/aws-accounts-{datetime.now()}.json"
    upload_file(file,key)
    
