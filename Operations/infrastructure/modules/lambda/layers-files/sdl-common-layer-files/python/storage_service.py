"""
This module is intended as an S3 storage service broker.
"""
from gzip import compress
import json
from botocore.config import Config

import boto3


class Bucket:
    """Service for storage operations"""

    def __init__(self, bucket_name, prefix, path):
        self.bucket = self.get_bucket(bucket_name)
        self.bucket_name = bucket_name
        self.path = path  # e.g. cdm
        self.prefix = prefix  # e.g. year=yyyy...

    def get_bucket(self, bucket):
        """This method gets a handle to an S3 bucket"""
        try:
            bucket = boto3.resource(
                "s3", config=Config(retries={"max_attempts": 15})
            ).Bucket(bucket)
            return bucket
        except Exception:
            return None

    def get_object(self, key):
        """This method returns the S3 object stored under key"""
        client = boto3.client("s3", config=Config(retries={"max_attempts": 15}))
        response = client.get_object(Bucket=self.bucket_name, Key=key)
        if response.get("Body"):
            return json.loads(response.get("Body").read())
        return {}

    def put_object(self, key, results):
        """This method stores an object in S3 under key"""
        if results:
            self.bucket.put_object(
                ACL="bucket-owner-full-control", Key=key, Body=results
            )

    def delete_object(self, key):
        """This method returns the S3 object stored under key"""
        client = boto3.client("s3", config=Config(retries={"max_attempts": 15}))
        for version in client.list_object_versions(
            Bucket=self.bucket_name, Prefix=key
        ).get("Versions", []):
            client.delete_object(
                Bucket=self.bucket_name, Key=key, VersionId=version.get("VersionId")
            )
        client.delete_object(Bucket=self.bucket_name, Key=key)

    def write_results(self, results, key):
        """This method compresses and stores a json document into the S3 bucket"""
        if results:
            self.put_object(key, compress(json.dumps(results).encode("utf-8")))
