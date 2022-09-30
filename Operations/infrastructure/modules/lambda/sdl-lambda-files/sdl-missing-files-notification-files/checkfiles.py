from common import Bucket, get_bucket
import json
import os
import time
from datetime import datetime, timedelta
from dateutil import tz
import sys
import boto3
from collections import Counter
from botocore.config import Config
import urllib.request
from functools import reduce

# time conversion variables
from_zone = tz.gettz('UTC')
to_zone = tz.gettz('America/New_York')

# get the s3 bucket and path
#BUCKET = os.getenv('BUCKET')

# get the slack channel url and id
SLACK_URL = os.getenv('SLACK_URL')
CHANNEL_ID = os.getenv('CHANNEL_ID')

# create an s3 client and resource
session = boto3.session.Session()
s3_client = session.client(service_name='s3')
s3_resource = session.resource(service_name='s3')



# function to paginate through s3 and check the timestamp
def get_s3_lastmodified_date(bucket_name, path, days, hours):
    status = True
    paginator = s3_client.get_paginator('list_objects')
    operation_parameters = {'Bucket': bucket_name,
                           'Prefix': path
                           }
                         
    page_paginator = paginator.paginate(**operation_parameters, PaginationConfig={'MaxItems': 500}, Delimiter='/')
    print('\n')
    filename: str = ''
    last_modified: str = ''
    last_date: str = ''
    last_day: int = 0
    days_since_received: int = 0
    Counter = 0
    file_ext = ['json', 'csv', 'gz']
   
    for page in page_paginator:
        if 'CommonPrefixes' in page:
            prefixes = [f['Prefix'] for f in page['CommonPrefixes']]
            for prefix in prefixes:
                print(prefix)
                get_last_modified_object(bucket_name, prefix, days, hours)
        else:
            get_last_modified_object(bucket_name, path, days, hours)

# get the UTC time now
def get_utc_now():
    current_day: int = 0
    current_date: str = ''
    utcdateformat = '%Y-%m-%d %H:%M:%S'
    localdateformat = '%Y-%m-%d %H:%M:%S %p'
    
    local_time = datetime.strptime(datetime.utcnow().strftime(utcdateformat), utcdateformat)
    local_time = local_time.replace(tzinfo=from_zone)
    local_time = local_time.astimezone(to_zone).strftime(localdateformat)
    #print(f"Local Time:: {local_time}")
    
    #time_now_UTC = datetime.utcnow().replace(tzinfo=from_zone)
    #print(f"UTC:: {time_now_UTC}")
    d = str(local_time)
    d = d.split(' ')
    current_date = d[0]
    current_day = int(current_date[-2:])
    #print(f"Current date:: {current_date}, Current day={current_day}")
    return local_time, current_date, current_day
    
# get last modified, date, day
def get_last_modified(last_modified):
    last_date: str = ''
    last_day: int = 0
    #print(f"Last Modified:: {last_modified}")
    l_date = str(last_modified)
    l_date = l_date.split(' ')
    last_date = l_date[0]
    last_day = int(last_date[-2:])
    #print(f"Last date:: {last_date}, Last day={last_day}")
    return last_modified, last_date, last_day

# get the last modified object and compare it to current date
def get_last_modified_object(bucket_name, prefix, days_to_validate, hours_to_validate):
    status = False
    validation_message: str = ''
    filename: str = ''
    last_file: str  = ''
    days_since_received: int = 0
    hours_since_received: int = 0
    last_modified: str = ''
    current_day: int = 0
    current_date: str = ''
    last_date: str = ''
    last_day: int = 0
    file_ext = ['json', 'csv', 'gz']
    path: str = ''

    # get the s3 resource and filter the bucket path
    bucket_objects = s3_resource.Bucket(bucket_name).objects.filter(Prefix=prefix)
    # get the s3 files object and sort in descending order
    files = [obj.key for obj in sorted(bucket_objects, key=lambda x: x.last_modified, reverse=True)]
    # get the sdl last modified files dates and sort in descending order
    modified_dates = [obj.last_modified for obj in sorted(bucket_objects, key=lambda x: x.last_modified, reverse=True)]
    
    #split the prefix and get the first item
    if prefix.startswith('snyk') or prefix.startswith('db_lookup'):
        path = prefix
    else:
        prefix = prefix.split('/')
        path = prefix[0]
    # assign the last modified date
    last_modified = modified_dates[0]
    # assign the last file
    last_file = files[0]
    # get the actual file name
    filename = str(last_file)
    filename = filename.split('/')[-1]
    #print(f"Actual File::: {filename}")
    # check the file name base on bucket path
    if path.startswith('snyk'):
        if filename.startswith('snyk-report') or filename.startswith('snyk-projects'):
            print(f"Snyk File Name::: {filename}")
            check_file_dates(bucket_name, path, filename, last_modified, days_to_validate, hours_to_validate)
         
    elif path.startswith('ispg-risk-pilot'):
        print(f"ispg-risk-pilot File Name::: {filename}")
        check_file_dates(bucket_name, path, filename, last_modified, days_to_validate, hours_to_validate)
    elif path.startswith('ion'):
        print(f"ion File Name::: {filename}")
        check_file_dates(bucket_name, path, filename, last_modified, days_to_validate, hours_to_validate)

# check the last day or hour since data was received in s3
def check_file_dates(bucket_name, path, filename, last_modified, days_to_validate, hours_to_validate):
    status = False
    validation_message: str = ''
    days_since_received: int = 0
    hours_since_received: int = 0
    current_day: int = 0
    current_date: str = ''
    last_date: str = ''
    last_day: int = 0
    # get current UTC date and day
    current_date = get_utc_now()[1]
    current_day = get_utc_now()[2]
    # get last date and day
    last_date = get_last_modified(last_modified)[1]
    last_day = get_last_modified(last_modified)[2]
    
    print(f"Last date:: {last_date}, Last day={last_day}")
    print(f"Current date:: {current_date}, Current day={current_day}")
    
    # get the days since data was received
    days_since_received = current_day - last_day
    print(f"Day(s)::: {days_since_received}")
    # evaluate the dates since last modified
    if current_date == last_date:
        status = True
        #print(f"Last file received on {last_date}, path={bucket_name}/{path}{filename}")
    # evaluate the hours since last modified
    elif hours_to_validate > 0:
        hours = get_utc_now()[0] - last_modified
        print(hours)
        hours = str(hours)[0:2]
        if hours.endswith(':'):
            hours_since_received = int(hours[0:1])
            if int(hours_since_received) < hours_to_validate:
                #print(f"Hours since data received:: {hours_since_received}")
                status = False
                print(f"Last file is:: {path}{filename}")
                validation_message = f"{hours_since_received} hour(s) has past since files were received in {bucket_name}/{path}"
                send_to_slack_channel(bucket_name, validation_message)
    # evaluate the day since last modified
    elif days_to_validate > 0 and days_since_received >= days_to_validate:
        print(f"Last file is:: {path}{filename}")
        #print(f"How Long:: {time_now_UTC - last_modified}")
        #print(f"{days_since_received} day(s) has past since data was received in {bucket_name}/{path}")
        status = False
        validation_message = f"{days_since_received} day(s) has past since data was received in {bucket_name}/{path}"
        send_to_slack_channel(bucket_name, validation_message)
            
    return validation_message



#####################################################
# aws, cdm, security-center validation method
#####################################################

# check file path if exist
def IsObjectExists(bucket_name, path):
    bucket = s3_resource.Bucket(bucket_name)
    for object_summary in bucket.objects.filter(Prefix=path):
        return True
    return False
    
# check path using each account id
def check_files_in_each_account_id(bucket_name, path, days_to_validate, hours_to_validate):
    status = False
    validation_message: str = ''
    days_since_last_modified: int = 0
    hours_since_last_modified: int = 0
    current_day: int = 0
    current_date: str = ''
    last_modified_date: str = ''
    last_modified_day: int = 0
    filename: str = ''
    # check if the file exist in the path before evaluating the last modified dates
    if(IsObjectExists(bucket_name, path)):
        bucket_objects = s3_resource.Bucket(bucket_name).objects.filter(Prefix=path)
        for obj in bucket_objects:
            #print(obj.key)
            #print(obj.last_modified)
            last_modified = obj.last_modified
            last_file = str(obj.key)
            filename = last_file.split('/')[-1]
            #print(f"Actual File:: {filename}")
            # get the utc current date and day
            current_date = get_utc_now()[1]
            current_day = get_utc_now()[2]
            # get the last date and day
            last_modified_date = get_last_modified(last_modified)[1]
            last_modified_day = get_last_modified(last_modified)[2]
            # print the dates
            #print(f"Last date:: {last_date}, Last day={last_day}")
            # get the days since last modified
            if last_modified_day > 0:
                days_since_last_modified = current_day - last_modified_day
            # evaluate the dates since last modified
            if current_date == last_modified_date:
                status = True
                print(f"Last file received on {last_modified_date}, path={bucket_name}/{path}{filename}")
            # evaluate the hours since last modified
            elif hours_to_validate > 0:
                hours = get_utc_now()[0] - last_modified
                print(hours)
                hours = str(hours)[0:2]
                if hours.endswith(':'):
                    hours_since_last_modified = int(hours[0:1])
                    if hours_to_validate > 0 and hours_since_last_modified >= hours_to_validate:
                        print(f"Last file was:: {path}{filename}")
                        validation_message = f"{hours_since_last_modified} hour(s) has past since files were received in {bucket_name}/{path}"
            # evaluate the days since last modified
            elif days_to_validate > 0 and days_since_last_modified >= days_to_validate:
                print(f"Last file was:: {path}{filename}")
                validation_message = f"{days_since_last_modified} days(s) has past since files were received in {bucket_name}/{path}"
    else:
        print(f"ERROR: s3 path not found:: {path}")
 
 # get the year, month, day
def get_year_month_day():
    utcdateformat = '%Y-%m-%d %H:%M:%S'
    localdateformat = '%Y-%m-%d %H:%M:%S %p'
    
    local_time = datetime.strptime(datetime.utcnow().strftime(utcdateformat), utcdateformat)
    local_time = local_time.replace(tzinfo=from_zone)
    local_time = local_time.astimezone(to_zone).strftime(localdateformat)
    d = str(local_time)
    d = d.split(' ')
    dd = str(d[0])
    dd = dd.split('-')
    year = dd[0]
    month = dd[1]
    day = dd[2]
    
    return year, month, day

############################################
# aws, cdm, security-center methods
############################################
def process_results(bucket_name, sdl_s3_path, days_to_validate, hours_to_validate):
    # get year, month, day
    year = get_year_month_day()[0]
    month = get_year_month_day()[1]
    day = get_year_month_day()[2]
    
    # open and read the json file contaning accounts
    config = json.load(open('data_center.json', 'r'))
    phases = config.get('datacenters')
    centers = json.dumps(phases)
    datacenters = json.loads(centers)
    s3_path = ''
    bucket = None
    # check if path is security-center
    if sdl_s3_path == 'security-center':
        # get the data center and path
        for datacenter in datacenters:
            s3_path = datacenters.get(datacenter).get('path')
            bucket = Bucket(bucket_name, s3_path)
            bucket.build_datacenter(datacenter, datacenters)
            if s3_path == 'security-center/':
                # get account from fisma system
                for fs in bucket.fisma_systems:
                    for account in fs.get('accounts'):
                        path = bucket.build_key(account, year, month, day)
                        #print(path)
                        check_files_in_each_account_id(bucket_name, path, days_to_validate, hours_to_validate)
                        
     # check if path is cdm                  
    elif sdl_s3_path == 'cdm':
        for datacenter in datacenters:
            s3_path = datacenters.get(datacenter).get('path')
            if not s3_path == 'cdm/':
                s3_path = 'cdm/'
            if s3_path == 'cdm/':
                bucket = Bucket(bucket_name, s3_path)
                bucket.build_datacenter(datacenter, datacenters)
                # get the accounts from fisma system
                for fs in bucket.fisma_systems:
                    for account in fs.get('accounts'):
                        path = bucket.build_key(account, year, month, day)
                        #print(path)
                        check_files_in_each_account_id(bucket_name, path, days_to_validate, hours_to_validate)
                        
    # check if path is aws
    elif sdl_s3_path == 'aws':
        print(sdl_s3_path)
        for datacenter in datacenters:
            s3_path = datacenters.get(datacenter).get('path')
            if not s3_path == 'aws/':
                s3_path = 'aws/'
            if s3_path == 'aws/':
                bucket = Bucket(bucket_name, s3_path)
                # initalize datacenter and fisma system
                bucket.build_datacenter(datacenter, datacenters)
                # get the accounts from fisma system
                for fs in bucket.fisma_systems:
                    for account in fs.get('accounts'):
                        path = bucket.build_key(account, year, month, day)
                        #print(path)
                        check_files_in_each_account_id(bucket_name, path, days_to_validate, hours_to_validate)
            
# send data to slack channel
def send_to_slack_channel(bucket_name, validation_message):
    print(validation_message)
    message_title = f"{bucket_name} missing files updates"
    print(message_title)
    #send the payload to slack channel
    checker = False
    payload={
    'channel':CHANNEL_ID,
        'attachments':[
        {
         "fallback":"AWS Step Function State Change",
         "pretext":"AWS Step Function State Change",
         "color":"#0000FF",
         "fields":[
            {
              "title":message_title,
              "value":validation_message,
              "short":checker
            }
         ]
        }
      ]
    }
    # use a request to send to slack chennel
    #req = urllib.request.Request(SLACK_URL, json.dumps(payload).encode('utf-8'))
    #resp = urllib.request.urlopen(req)

