import json
import random
import boto3
import string

def lambda_handler(event, context):
    random_data = ''.join(random.choices(string.ascii_letters + string.digits, k=20))
    encoded_string = random_data.encode('utf-8')
    
    file_name = 'random_data.txt'
    bucket = 'natest-other-destination'
    
    # Would typically create a random file name here, but keeping the same to reduce overall storage usage
    
    s3 = boto3.client("s3")
    
    response = s3.put_object(Bucket=bucket, Key=file_name, Body=encoded_string)
    
    statusCode = 200
    return {
        'statusCode': statusCode,
        'body': json.dumps(response),
        'headers': {
            'Content-Type': 'application/json'
        }
    }
