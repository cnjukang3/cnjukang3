import json
import datetime
from dateutil import tz
import urllib.request
import os


# get the slack chennel url and id
SLACK_URL = os.getenv('SLACK_URL')
CHANNEL_ID = os.getenv('CHANNEL_ID')

# declare dict variables to hold raw data
state_machine_name = None
step_status = None
raw_data_1 = {}
raw_data_2 = {}
results = {}

# declare the date and time conversion variables
from_zone = tz.gettz('UTC')
to_zone = tz.gettz('America/New_York')

# collect the data
def gather_data(response):
    # loop through the json object the get the key/value pair
    for key, value in response.items():
        if key == 'detail':
            results.update(value)
        else:
            raw_data_1[key]=value
    # extract the data from results
    for k, val in results.items():
        if key == 'output':
            pass
        else:
            raw_data_2[k]=val
            
            
# convert date/time to local time and add data into a set
def aggregate_data():
    # data will be included for the following keys
    data_keys = ['region', 'input', 'status']
    # define a set to store the data extracted
    aggregate_set = set()
    rx = None
    # get the data from dict 1 and dict 2
    raw_data_3 = {**raw_data_1, **raw_data_2}
    print('--------------------< AWS Notifications >--------------------------')
    # add the data into a collection
    for x, y in raw_data_3.items():
        rx = str(x)
        utcdateformat = '%Y-%m-%d %H:%M:%S'
        locatdateformat = '%m/%d/%Y %H:%M:%S %p'
        startdate_key = 'START DATE'
        stopdate_key = 'STOP DATE'
        if rx == 'stateMachineArn':
            sm = str(y)
            sm_list = sm.split(':')
            # reverse the order of the list and get the first item
            # which corresponse to the state machine name
            result = []
            for item in sm_list:
                result.insert(0, item)
            state_machine = str(result[:1])
            rx = 'State Machine'
            aggregate_set.add(rx + ':  ' + state_machine.strip()[2:-2])
            # convert the start date into local date/time
        elif rx == 'startDate':
            utc_st = datetime.datetime.fromtimestamp(int(y)/1000).strftime(utcdateformat)
            start_utc = datetime.datetime.strptime(utc_st, utcdateformat)
            start_utc = start_utc.replace(tzinfo=from_zone)
            start_date = start_utc.astimezone(to_zone)
            rx = startdate_key
            aggregate_set.add(rx + ':  ' + str(datetime.datetime.strftime(start_date, locatdateformat)))
            # convert the stop date into local date/time
        elif rx == 'stopDate':
            utc_sp = datetime.datetime.fromtimestamp(int(y)/1000).strftime(utcdateformat)
            stop_utc = datetime.datetime.strptime(utc_sp, utcdateformat)
            stop_utc = stop_utc.replace(tzinfo=from_zone)
            stop_date = stop_utc.astimezone(to_zone)
            rx = stopdate_key
            aggregate_set.add(rx + ':  ' + str(datetime.datetime.strftime(stop_date, locatdateformat)))
            # add the key/value for data_keys above
        elif rx in data_keys:
            aggregate_set.add(rx + ':  ' + str(y))
        
    return aggregate_set    
    
# sort the message to send to slack channel
def send_to_slack_channel(response_text):
    # define a sorted set for the message
    sort_response_text = set()
    slackmessage = ""
    sort_response_text = sorted(response_text)
    # get the step function name and status
    for x in sort_response_text:
        y = x.split(':')
        it = iter(y)
        z = zip(it, it)
        for a, b in z:
            if a == 'State Machine':
                state_machine_name = str(b)
            elif a == 'status':
                step_status = str(b)
    # concatinate the data in the set into a string
    for s in sort_response_text:
        slackmessage += str(s+' '+'\n')

    # message title
    message_title = f"Step Function Name: {state_machine_name}, status: {step_status}"
    # send the payload to slack channel
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
              "value":slackmessage,
              "short":checker
            }
          ]
        }
      ]
    }
    req = urllib.request.Request(SLACK_URL, json.dumps(payload).encode('utf-8'))
    resp = urllib.request.urlopen(req)
    
            
def lambda_handler(event, context):
    # convert event into json string
    strdata = json.dumps(event)
    # convert json string into json object
    response = json.loads(strdata)
    # call the function to gather data from eventbridge
    gather_data(response)
    # send the notification to slack channel (security-datalake-alert)
    aws_notification = aggregate_data()
    return send_to_slack_channel(aws_notification)
   










