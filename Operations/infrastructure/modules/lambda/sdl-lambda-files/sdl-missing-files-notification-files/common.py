from botocore.config import Config
from gzip import compress
import boto3
import json
import os


def get_bucket(bucket):
    bucket = boto3.resource('s3', config=Config(retries = {'max_attempts': 15})).Bucket(bucket)
    try:
        return bucket
    except Exception as e:
        return None

class Bucket:
    def __init__(self, bucket_name, path):
        self.bucket = get_bucket(bucket_name)
        self.bucket_name = bucket_name
        self.path = path
        self.fisma_systems = None
        self.datacenter = None
        self.default = None
    
    # get the datacenters, Fisma Systems and default
    def build_datacenter(self, datacenter, datacenters):
        self.datacenter = datacenters.get(datacenter).get('datacenter')
        self.fisma_systems = datacenters.get(datacenter).get('fisma_systems')
        self.default = datacenters.get(datacenter).get('default')
        #print("DD: ", datacenters.get(datacenter).get('datacenter'))
        #print("FIS: ", datacenters.get(datacenter).get('fisma_systems'))
        #print("DF: ", datacenters.get(datacenter).get('default'))
    
    # get the fisma system
    def get_fisma_system(self, account):
        for fs in self.fisma_systems:
            if account in fs.get('accounts'):
                #print('accountid='+account)
                return fs.get('fisma_system')
        return self.default
    # construct the s3 path
    def build_key(self, account, year, month, day):
        tags, fisma_system = [], self.get_fisma_system(account)
        for key in fisma_system:
            tags.append(f"{key}={fisma_system.get(key)}")
        acronym = fisma_system.get('Acronym').replace(" - ", "-").replace(" ", "-").lower()
        #print(f"Fisma System Acronym: {acronym}")
        if self.path == 'security-center/':
            return f"{self.path}{'56FFF52E-175B-4E48-9B38-669C8BC74899'}/{fisma_system.get('UID')}/{acronym}/year={year}/month={month}/day={day}/accountid={account}/"
        else:
            return f"{self.path}{self.datacenter}/{fisma_system.get('UID')}/{acronym}/year={year}/month={month}/day={day}/accountid={account}/"
             
