from datetime import datetime
import boto3
import json
import uuid
import os

SDLMACHINE = os.getenv('SDLMACHINE')

def build_init(prefix, feeds):
    response = []
    for stage in feeds:
        for phase in feeds.get(stage):
            response.append({'stage': stage, 'phase': phase, 'prefix': prefix, **feeds.get(stage).get(phase)})
    return json.dumps(response)

def init_central(step_function, feeds):
    print(build_init(datetime.now().strftime('year=%Y/month=%m/day=%d'), feeds))
    return
    client = boto3.client('stepfunctions')
    response = client.start_execution(
        stateMachineArn=step_function,
        name=f"sdl-daily-ingest-{datetime.now().strftime('%Y-%m-%d')}-{uuid.uuid4()}",
        input=build_init(datetime.now().strftime('year=%Y/month=%m/day=%d'), feeds)
    )

def lambda_handler(event, context):
    if event.get('source') == 'aws.events':
        init_central(SDLMACHINE, json.load(open('config.json', 'r')))
