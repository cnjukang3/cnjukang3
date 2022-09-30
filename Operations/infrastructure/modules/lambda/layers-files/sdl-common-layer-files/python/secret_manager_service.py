"""
This module is intended to possess Secret management related services.
"""
import json
import boto3


class SecretManager:
    """Service for the management of sensitive secret items"""
    def get_secret(self, secret_name):
        """Retrieve secret from the secret manager using secret_name as key"""
        if secret_name.strip():
            return json.loads(
                boto3.client("secretsmanager")
                .get_secret_value(SecretId=secret_name)
                .get("SecretString")
            )
