import json
import boto3
import os
from decimal import Decimal

# We import decimal and use the encoder to "clean" the data into a format that JSON accepts. 
# Without it, the code will return a decimal value that isn't compatiable with JSON

class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)

def lambda_handler(event, context):
   
    dynamodb = boto3.resource('dynamodb')
    table_name = dynamodb.Table(os.environ['DDB_table'])
   
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
