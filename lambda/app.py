import os
import boto3
import uuid
import json
import time
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = "cache-token_table"
AWS_REGION_JEFF = os.environ.get("AWS_REGION")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")



def lambda_handler(event, _context):
    token = str(uuid.uuid4)
    expires_at = int(time.time() + 86000)
    
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(
        Item={
            "id": "token",
            "token": token,
            "expires_at": expires_at
        })
    
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="Novo Token Gerado",
        Message=f"Token: {token}\nExpira em: {datetime.utcfromtimestamp(expires_at)} UTC"
    )
    
    return {
        "statusCode": 200,
        "body": json.dumps({"token": token, "expires_at": expires_at, "region": AWS_REGION_JEFF}) 
    }