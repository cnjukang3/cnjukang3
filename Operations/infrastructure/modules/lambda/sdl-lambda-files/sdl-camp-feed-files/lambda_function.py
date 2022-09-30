from datetime import datetime
import json
import uuid
import os

APIKEY = os.getenv('APIKEY');
CAMPURL = os.getenv('CAMPURL');
BUCKET = os.getenv('BUCKET'); #security-staging-daily
BUCKETPATH = os.getenv('BUCKETPATH'); #/config

def lambda_handler(event, context):

    campQueryParams = {"apikey": APIKEY, "select": "short_app_name,fisma_acronym,acct_num,acct_name" };
    print(f'Getting bucket: {BUCKET}');
    bucket = Bucket(BUCKET, None, BUCKETPATH);
    print(f'Bucket has been got ');
    try:
        print(f'About to call {CAMPURL}');
        # finalurl= f"{CAMPURL}?apikey={APIKEY}"
        # print(f'calling final url of {finalurl}');
        campResponse = requests.get(CAMPURL, params=campQueryParams);
        # campResponse = requests.get(finalurl);
        print(f'Called and returned from {finalurl}');
        campResponse.raise_for_status();
        print(f'Writing results');
        bucket.write_results(campResponse.json, 'camp');
    # except requests.exceptions.Exception as e:
    except Exception as e:
        print(f'An error ocurred while calling CAMP {str(e)}');
        # print(str{e});
        #raise Exception(f"ERROR: {str(e)}");
