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
            response.append({'message': {'stage': stage, 'prefix': prefix, **phase}})
    return json.dumps(response)

def init_central(step_function, feeds):
    client = boto3.client('stepfunctions')
    response = client.start_execution(
        stateMachineArn=step_function,
        name=f"sdl-daily-ingest-vuln-csm-config-{datetime.now().strftime('%Y-%m-%d')}-{uuid.uuid4()}",
        input=build_init(datetime.now().strftime('year=%Y/month=%m/day=%d'), feeds)
    )

def lambda_handler(event, context):
    if event.get('source') == 'aws.events':
        init_central(SDLMACHINE, json.load(open('config.json', 'r')))
