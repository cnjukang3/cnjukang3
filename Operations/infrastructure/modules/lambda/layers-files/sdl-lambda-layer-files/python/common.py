from botocore.config import Config
from gzip import compress
import boto3
import json
import os

def get_secret(secretName):
    if secretName.strip():
        return json.loads(boto3.client("secretsmanager").get_secret_value(SecretId=secretName).get("SecretString"))

def get_bucket(bucket):
    bucket = boto3.resource('s3', config=Config(retries = {'max_attempts': 15})).Bucket(bucket)
    try:
        return bucket
    except Exception as e:
        return None

def build_entries(results):
    response = []
    for entry in results:
        item = {**entry.get('configuration')}
        for key in entry:
            if key == 'configuration':
                continue
            item[key] = entry.get(key)
        response.append(item)
    return response

class Bucket:
    def __init__(self, bucket_name, prefix, path):
        self.bucket = get_bucket(bucket_name)
        self.bucket_name = bucket_name
        self.prefix = prefix
        self.path = path
        self.fisma_systems = None
        self.datacenter = None
        self.default = None

    def build_datacenter(self, datacenter, datacenter_path):
        datacenters = self.get_object(datacenter_path)
        if datacenter in datacenters:
            self.datacenter = datacenters.get(datacenter).get('datacenter')
            self.fisma_systems = datacenters.get(datacenter).get('fisma_systems')
            self.default = datacenters.get(datacenter).get('default')

    def get_object(self, key):
        client = boto3.client('s3', config=Config(retries = {'max_attempts': 15}))
        response = client.get_object(Bucket=self.bucket_name, Key=key)
        if response.get('Body'):
            return json.loads(response.get('Body').read())
        return {}

    def put_object(self, key, results):
        if results:
            self.bucket.put_object(ACL='bucket-owner-full-control', Key=key, Body=results)

    def delete_object(self, key):
        client = boto3.client('s3', config=Config(retries = {'max_attempts': 15}))
        for version in client.list_object_versions(Bucket=self.bucket_name, Prefix=key).get('Versions', []):
            client.delete_object(Bucket=self.bucket_name, Key=key, VersionId=version.get('VersionId'))
        client.delete_object(Bucket=self.bucket_name, Key=key)

    def get_fisma_system(self, account):
        for fs in self.fisma_systems:
            if account in fs.get('accounts'):
                return fs.get('fisma_system')
        return self.default

    def build_key(self, account, source_type):
        fisma_system = self.get_fisma_system(account)
        acronym = fisma_system.get('Acronym').replace(" - ", "-").replace(" ", "-").lower()
        return f"{self.path}{self.datacenter}/{fisma_system.get('UID')}/{acronym}/{self.prefix}/accountid={account}/{source_type}.json.gz"

    def write_results(self, results, account, source_type):
        if results:
            self.put_object(self.build_key(account, source_type), compress(json.dumps(results).encode('utf-8')))

class ConfigDelegate:
    def __init__(self, secret_string):
        self.aggregator = None
        self.region = None
        self.access_keys = None
        self.process_secret(secret_string)

    def process_secret(self, secret_string):
        secret_value = get_secret(os.getenv(secret_string))
        self.aggregator = secret_value.get('aggregator')
        self.region = secret_value.get('region')
        self.generate_access_keys(secret_value)

    def generate_access_keys(self, secret_value, session_name='cms-cloud-dragnet-infrastructure'):
        try:
            if secret_value.get("secret_access_key") and secret_value.get("access_key_id"):
                self.access_keys = {'AccessKeyId': secret_value.get("access_key_id"), 'SecretAccessKey': secret_value.get("secret_access_key")}
            if secret_value.get("role") and secret_value.get("external_id"):
                self.access_keys = boto3.client('sts').assume_role(RoleArn=secret_value.get("role"), ExternalId=secret_value.get("external_id"), RoleSessionName=session_name).get('Credentials')
            if not self.access_keys:
                raise Exception(f"ERROR: No Credentials")
        except Exception as e:
            raise Exception(f"ERROR: {e}")

    def get_client(self):
        return boto3.client(
            'config',
            aws_access_key_id=self.access_keys.get('AccessKeyId'),
            aws_secret_access_key=self.access_keys.get('SecretAccessKey'),
            aws_session_token=self.access_keys.get('SessionToken'),
            region_name=self.region,
            config=Config(retries = {'max_attempts': 15})
        )

    def get_global(self):
        response = {}
        for resource in self.get_query_results("SELECT\n  accountId,\n  COUNT(*)\nWHERE\n  resourceType = 'AWS::CloudFormation::Stack'\n  AND resourceName IN (\n    'cms-cloud-global-config',\n    'CMS-Cloud-CDM-Support-Config-West',\n    'CMS-Cloud-CDM-Support-Config-East'\n  )\n  AND configuration.stackStatus IN ('CREATE_COMPLETE', 'UPDATE_COMPLETE')\nGROUP BY\n  accountId\n"):
            response[resource.get('accountId')] = resource.get('COUNT(*)')
        return response

    def get_query_results(self, select, where, max_results=100):
        query = f"SELECT {select} WHERE {where}"
        client = self.get_client()
        results,token = [], None
        while True:
            if token:
                response = client.select_aggregate_resource_config(Expression=query, ConfigurationAggregatorName=self.aggregator, MaxResults=max_results, NextToken=token)
            else:
                response = client.select_aggregate_resource_config(Expression=query, ConfigurationAggregatorName=self.aggregator, MaxResults=max_results)
            results += [json.loads(entry) for entry in response.get('Results', [])]
            if response.get('NextToken'):
                token = response.get('NextToken')
            else:
                break
        return results

    def gather_accounts(self):
        results = []
        NextToken = None
        client = self.get_client()
        while True:
            if NextToken:
                response = client.describe_configuration_aggregator_sources_status(ConfigurationAggregatorName=self.aggregator, Limit=100, NextToken=NextToken)
            else:
                response = client.describe_configuration_aggregator_sources_status(ConfigurationAggregatorName=self.aggregator, Limit=100)
            for entry in response.get('AggregatedSourceStatusList', []):
                if entry.get('SourceId') not in results and entry.get('SourceId') != 'Organization':
                    results.append(entry.get('SourceId'))
            if response.get('NextToken'):
                NextToken = response.get('NextToken')
            else:
                return results

class AssumeRole:
    def __init__(self, account, role, external_id, service_account, partition, session_name='iusg-sdl-cdm-operations'):
        self.role = f"arn:{partition}:iam::{account}:role/{role}"
        self.external_id = external_id
        self.session = session_name
        self.access_keys = self.generate_access_keys(get_secret(os.getenv(service_account)) if partition == 'aws-us-gov' else None)

    def generate_access_keys(self, access_keys):
        try:
            if not self.role or not self.external_id:
                raise Exception(f"ERROR: No Role or ExternalId -> Role: {self.role} ExternalId: {self.external_id}")
            if access_keys:
                access_keys = boto3.client('sts', aws_access_key_id=access_keys.get('access_key_id'), aws_secret_access_key=access_keys.get('secret_access_key'), region_name=access_keys.get('region'), config=Config(retries = {'max_attempts': 15})).assume_role(RoleArn=self.role, ExternalId=self.external_id, RoleSessionName=self.session).get('Credentials')
            else:
                access_keys = boto3.client('sts').assume_role(RoleArn=self.role, ExternalId=self.external_id, RoleSessionName=self.session).get('Credentials')
            if access_keys:
                return access_keys
            raise Exception(f"ERROR: {self.role} No Access Keys")
        except Exception as e:
            raise Exception(f"ERROR: {self.role} {e}")

    def get_client(self, resource, region="us-east-1"):
        return boto3.client(
            resource,
            aws_access_key_id=self.access_keys.get('AccessKeyId'),
            aws_secret_access_key=self.access_keys.get('SecretAccessKey'),
            aws_session_token=self.access_keys.get('SessionToken'),
            region_name=region,
            config=Config(retries = {'max_attempts': 15})
        )

    def get_resource(self, resource, region="us-east-1"):
        return boto3.resource(
            resource,
            aws_access_key_id=self.access_keys.get('AccessKeyId'),
            aws_secret_access_key=self.access_keys.get('SecretAccessKey'),
            aws_session_token=self.access_keys.get('SessionToken'),
            region_name=region,
            config=Config(retries = {'max_attempts': 15})
        )
