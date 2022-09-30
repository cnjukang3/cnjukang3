"""
This module is intended to contain IAM related functions
for resources assuming adequate roles for operations.
"""
from botocore.config import Config
from gzip import compress
import boto3
import json
import os


def get_secret(secretName):
    if secretName.strip():
        return json.loads(boto3.client("secretsmanager").get_secret_value(SecretId=secretName).get("SecretString"))


class AssumeRole:
    """Service for the management of credentialing"""

    def __init__(self, account, role, external_id, service_account, partition, session_name='iusg-sdl-cdm-operations'):
        self.role = f"arn:{partition}:iam::{account}:role/{role}"
        self.external_id = external_id
        self.session = session_name
        self.access_keys = self.generate_access_keys(get_secret(os.getenv(service_account)) if partition == 'aws-us-gov' else None)


    def generate_access_keys(self, access_keys):
        """Get credentials of assumed role"""
        try:
            if not self.role or not self.external_id:
                raise Exception(
                    f"ERROR:No Role or ExternalId- Role: {self.role} ExternalId: {self.external_id}"
                )
            if access_keys:
                access_keys = (
                    boto3.client(
                        "sts",
                        aws_access_key_id=access_keys.get("access_key_id"),
                        aws_secret_access_key=access_keys.get("secret_access_key"),
                        region_name=access_keys.get("region"),
                        config=Config(retries={"max_attempts": 15}),
                    )
                    .assume_role(
                        RoleArn=self.role,
                        ExternalId=self.external_id,
                        RoleSessionName=self.session,
                    )
                    .get("Credentials")
                )
            else:
                access_keys = (
                    boto3.client("sts")
                    .assume_role(
                        RoleArn=self.role,
                        ExternalId=self.external_id,
                        RoleSessionName=self.session,
                    )
                    .get("Credentials")
                )
            if access_keys:
                return access_keys
            raise Exception(f"ERROR: {self.role} No Access Keys")
        except Exception as access_keys_error:
            raise Exception(f"ERROR: {self.role} - {access_keys_error}") from access_keys_error

    def get_client(self, resource, region="us-east-1"):
        """This method might be redundant and be removed"""
        return boto3.client(
            resource,
            aws_access_key_id=self.access_keys.get("AccessKeyId"),
            aws_secret_access_key=self.access_keys.get("SecretAccessKey"),
            aws_session_token=self.access_keys.get("SessionToken"),
            region_name=region,
            config=Config(retries={"max_attempts": 15}),
        )

    def get_resource(self, resource, region="us-east-1"):
        """This method might be redundant and be removed"""
        return boto3.resource(
            resource,
            aws_access_key_id=self.access_keys.get("AccessKeyId"),
            aws_secret_access_key=self.access_keys.get("SecretAccessKey"),
            aws_session_token=self.access_keys.get("SessionToken"),
            region_name=region,
            config=Config(retries={"max_attempts": 15}),
        )
