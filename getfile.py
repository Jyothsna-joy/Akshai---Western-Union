import base64
import boto3


s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucketname = event ["pathParameters"]["bucket"]
    filename = event ["queryStringParameters"]["file"]
    fileObj = s3.get_object(Bucket=bucketname, Key=filename)
    file_content = fileObj["Body"].read()
    # print
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/jpg",
            "Content-Disposition": "attachment; filename={}".format(filename)
        },
        "body": base64.b64encode(file_content),
        "isBase64Encoded": True
    }