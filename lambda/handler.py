import os

import boto3


def get_parameter(name):
    try:
        ssm = boto3.client("ssm")
        response = ssm.get_parameter(Name=name, WithDecryption=False)
        return response["Parameter"]["Value"]
    except Exception as err:
        return "__DYNAMIC_STRING_NOT_FOUND__"


def lambda_handler(event, context):
    parameter_name = os.getenv("PARAMETER_NAME", "my-parameter")

    html = f"<h1>The saved string is {get_parameter(parameter_name)}</h1>"

    return {"statusCode": 200, "headers": {"Content-Type": "text/html"}, "body": html}
