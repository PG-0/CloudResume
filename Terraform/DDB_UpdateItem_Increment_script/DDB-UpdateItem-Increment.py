import boto3
import json
import os

def lambda_handler(event, context):

    # Get the DDB service resource
    dynamodb = boto3.resource("dynamodb")

    # Initialize Table
    table = dynamodb.Table(os.environ['DDB_table'])

    # Update Counter in Table
    response = table.update_item(
        Key={'visitorID': 'visitor-x'},
        UpdateExpression="SET visit_count = visit_count + :inc",
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW",
    )

    print(response['Attributes'])

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully Updated DynamoDB Table CR-Counter.'),
    }