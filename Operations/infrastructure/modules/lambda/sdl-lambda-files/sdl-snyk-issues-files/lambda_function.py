from datetime import datetime
import boto3
import json
import requests
import os

APIKEY = os.getenv('APIKEY');
SNYKURL = os.getenv('SNYKURL');
BUCKET = os.getenv('BUCKET');
BUCKETPATH = os.getenv('BUCKETPATH');

headers = {'Content-Type': 'application/json; charset=utf-8',  'Authorization': f'token {APIKEY}'}

def upload_file(file,key):
    client=boto3.client('s3')
    client.put_object(Body=file, Bucket=BUCKET, Key=key,ContentType='application/json')

def lambda_handler(event, context):
    response = requests.get(f'{SNYKURL}/orgs', headers=headers)
    response_orgs=response.json()['orgs']
    resp_id=[resp['id'] for resp in response_orgs]
    input_data=json.load(open('input.json','r'))
    input_data['filters']['orgs']=resp_id
    url=f'{SNYKURL}/reporting/issues/latest/?page=1&perPage=1'
    response = requests.post(url,data=json.dumps(input_data),headers=headers)
    count=response.json()['total']
    pgcount=(count/1000)+1
    i=1
    while i < pgcount:
        url=f'{SNYKURL}/reporting/issues/latest/?page={i}&perPage=1000'
        response = requests.post(url,data=json.dumps(input_data),headers=headers)
        file=json.dumps(response.json())
        key=f"{BUCKETPATH}/{datetime.now().strftime('%Y/%m/%d')}/snyk-report-{datetime.now().strftime('%Y-%m-%d')}-page-{i:04d}.json"
        upload_file(file,key)
        i=i+1    
    