"""
Lambda function for generating and storing AWS config data
"""
import os
from config_delegate_service import ConfigDelegate
from config_data import config_data

GOVCLOUDROLE = os.getenv("GOVCLOUDROLE")

config_delegates = {"AWS GovCloud": "CONFIGDELEGATEGOVCLOUD", "AWS": "CONFIGDELEGATE"}

def build_init(prefix, phases, stage="sdl-aws-cdm-config_data-feed"):
    """get all the account ids from config delegates associated with EC2 Instances"""
    response = []
    for datacenter in config_delegates:
        config_delegate = config_delegates.get(datacenter)
        accounts = [
            account.get("accountId")
            for account in ConfigDelegate(config_delegate).get_query_results(
                "accountId, count(*)",
                "resourceType = 'AWS::EC2::Instance' GROUP BY accountId",
            )
        ]
        response += [
            {
                "message": {
                    "stage": stage,
                    "prefix": prefix,
                    "phases": phases,
                    "account": account,
                    "hwam": [],
                    "datacenter": datacenter,
                }
            }
            for account in accounts
        ]
    return response


def start_phase(event):
    phase = event.get("phases").pop(0)
    if not phase in ['config_data']:
        event['phases'] = ['complete']

        return event
    # generate config data
    elif phase in ['config_data']:
        return config_data(event, ConfigDelegate(config_delegates.get(event.get("datacenter"))))
    raise Exception(
        f"Invalid Phase: {phase} - for Account: {event.get('account')} - Config Delegate: {event.get('config_delegate')}"
    )


def lambda_handler(event, context):
    event = event.get("message")
    if event.get("stage") == "sdl-daily-aws-vcc":  # sdl-daily-aws-vcc is the name of the step function that calls this lambda
        return build_init(event.get("prefix"), event.get("phases"))
    elif event.get("phases"):
        return {"message": start_phase(event)}


