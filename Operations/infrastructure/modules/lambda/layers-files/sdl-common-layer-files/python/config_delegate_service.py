"""
This module is intended to create and manage a config
delegate for querying aws config account data.
"""
import os
import json
from botocore.config import Config
import boto3

from secret_manager_service import SecretManager

class ConfigDelegate:
    def __init__(self, secret_string):
        self.aggregator = None
        self.region = None
        self.access_keys = None
        self.secret_manager = SecretManager()
        self.process_secret(secret_string)

    def process_secret(self, secret_string):
        secret_value = self.secret_manager.get_secret(os.getenv(secret_string))
        self.aggregator = secret_value.get("aggregator")
        self.region = secret_value.get("region")
        self.generate_access_keys(secret_value)

    def generate_access_keys(
        self, secret_value, session_name="cms-cloud-dragnet-infrastructure"
    ):
        """Get credentials of assumed role"""
        try:
            role = secret_value.get("role")
            if secret_value.get("secret_access_key") and secret_value.get(
                "access_key_id"
            ):
                self.access_keys = {
                    "AccessKeyId": secret_value.get("access_key_id"),
                    "SecretAccessKey": secret_value.get("secret_access_key"),
                }
            if role and secret_value.get("external_id"):
                self.access_keys = (
                    boto3.client("sts")
                    .assume_role(
                        RoleArn=role,
                        ExternalId=secret_value.get("external_id"),
                        RoleSessionName=session_name,
                    )
                    .get("Credentials")
                )
            if not self.access_keys:
                raise Exception("ERROR: No Credentials")
        except Exception as access_keys_error:
            raise Exception(f"ERROR: {role}") from access_keys_error

    def get_client(self):
        return boto3.client(
            "config",
            aws_access_key_id=self.access_keys.get("AccessKeyId"),
            aws_secret_access_key=self.access_keys.get("SecretAccessKey"),
            aws_session_token=self.access_keys.get("SessionToken"),
            region_name=self.region,
            config=Config(retries={"max_attempts": 15}),
        )

    def get_global(self):
        response = {}
        for resource in self.get_query_results(
            "accountId,\n  COUNT(*)\n",
            "resourceType = 'AWS::CloudFormation::Stack'\n" +
            "  AND resourceName IN (\n    'cms-cloud-global-config',\n" +
            "  'CMS-Cloud-CDM-Support-Config-West',\n   'CMS-Cloud-CDM-Support-Config-East'\n )\n" +
            "  AND configuration.stackStatus IN " +
            "('CREATE_COMPLETE', 'UPDATE_COMPLETE')\nGROUP BY\n  accountId\n"
        ):
            response[resource.get("accountId")] = resource.get("COUNT(*)")
        return response

    def get_query_results(self, select, where, max_results=100):
        query = f"SELECT {select} WHERE {where}"
        client = self.get_client()
        results, token = [], None
        while True:
            if token:
                response = client.select_aggregate_resource_config(
                    Expression=query,
                    ConfigurationAggregatorName=self.aggregator,
                    MaxResults=max_results,
                    NextToken=token,
                )
            else:
                response = client.select_aggregate_resource_config(
                    Expression=query,
                    ConfigurationAggregatorName=self.aggregator,
                    MaxResults=max_results,
                )
            results += [json.loads(entry) for entry in response.get("Results", [])]
            if response.get("NextToken"):
                token = response.get("NextToken")
            else:
                break
        return results

    def gather_accounts(self):
        results = []
        next_token = None
        client = self.get_client()
        while True:
            if next_token:
                response = client.describe_configuration_aggregator_sources_status(
                    ConfigurationAggregatorName=self.aggregator,
                    Limit=100,
                    NextToken=next_token,
                )
            else:
                response = client.describe_configuration_aggregator_sources_status(
                    ConfigurationAggregatorName=self.aggregator, Limit=100
                )
            for entry in response.get("AggregatedSourceStatusList", []):
                if (
                    entry.get("SourceId") not in results
                    and entry.get("SourceId") != "Organization"
                ):
                    results.append(entry.get("SourceId"))
            if response.get("NextToken"):
                next_token = response.get("NextToken")
            else:
                return results