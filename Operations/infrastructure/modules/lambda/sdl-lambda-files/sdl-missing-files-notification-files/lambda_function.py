import json
import os
import time
from checkfiles import get_s3_lastmodified_date, process_results

# get the s3 bucket and paths
BUCKET = os.getenv('BUCKET')
AWS_PATH = os.getenv('AWS_PATH')
CDM_PATH = os.getenv('CDM_PATH')
DB_LOOKUP_PATH = os.getenv('DB_LOOKUP_PATH')
DW_PATH = os.getenv('DW_PATH')
ION_PATH = os.getenv('ION_PATH')
ISPG_RISK_PILOT_PATH = os.getenv('ISPG_RISK_PILOT_PATH')
NUCLEUS_PATH = os.getenv('NUCLEUS_PATH')
SECURITY_CENTER_PATH = os.getenv('SECURITY_CENTER_PATH')
SNYK_PATH = os.getenv('SNYK_PATH')



def lambda_handler(event, context):
    # get the files from s3 and check the timestamp
    t = time.localtime()
    df = '%m/%d/%Y  %H:%M:%S %p'
    now = time.strftime(df, t)
    snyk_dw_ion_ispg_path = [SNYK_PATH, DW_PATH, ION_PATH, ISPG_RISK_PILOT_PATH]
    # check for snyk, ion, DW, ispg-risk-pilot
    days_d = 2
    hours_h = 0
    for sdl_path in snyk_dw_ion_ispg_path:
        get_s3_lastmodified_date(BUCKET, sdl_path, days_d, hours_h)
    
    # check the aws/ cdm/ and security-center/ path
    aws_cdm_security_center_path = [AWS_PATH, CDM_PATH, SECURITY_CENTER_PATH]
    days = 2
    hours = 0
    for path in aws_cdm_security_center_path:
        process_results(BUCKET, path, days, hours)
    return now
