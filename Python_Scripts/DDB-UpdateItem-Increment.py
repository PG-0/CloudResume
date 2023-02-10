import boto3
import json


def lambda_handler(event, context):

    # Get the DDB service resource
    dynamodb = boto3.resource("dynamodb")

    # Initialize Table
    table = dynamodb.Table('CR-Counter')

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

# ---
# Breaking Down the below code
# Keep in mind the depdencies of getting the DDB resource  and table above
# ---
    # response = table.update_item(  ---> We are creating a variable 'response'
    #     Key={'visitorID': 'visitor-x'},   ---> # We are calling the table and using the update item API for DDB
    #     UpdateExpression="SET visit_count = visit_count + :inc",
    #     ExpressionAttributeValues={':inc': 1},
    #     ReturnValues="UPDATED_NEW",





# The 'Key' attribute specifies the tables PK so we specify which record/item to update
# The 'UpdateExpression' 