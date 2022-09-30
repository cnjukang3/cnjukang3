from botocore.config import Config
from gzip import compress
import boto3
import json
import os


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
        self.bucket = self.get_bucket(bucket_name)
        self.bucket_name = bucket_name
        self.prefix = prefix
        self.path = path

    def get_bucket(self, bucket):
        bucket = boto3.resource('s3', config=Config(retries = {'max_attempts': 15})).Bucket(bucket)
        try:
            return bucket
        except Exception as e:
            return None

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

    def build_key(self, fileName):
        return f"{self.path}/{fileName}.json.gz"

    def write_results(self, results, fileName):
        if results:
            self.put_object(self.build_key(fileName), compress(json.dumps(results).encode('utf-8')))
