import json
import boto3
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)

def lambda_handler(event, context):
   
    dynamodb = boto3.resource('dynamodb')
    table_name = dynamodb.Table('CR-Counter')
   
    response = table_name.get_item(
      Key = {'visitorID':'visitor-x'},
      ProjectionExpression="visit_count"
    )
    count = response['Item']['visit_count']
    print(count)
   
    return {
        'statusCode': 200,
        'body': json.dumps(count, cls=DecimalEncoder)
    }
