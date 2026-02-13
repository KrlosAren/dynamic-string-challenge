# Dynamic String Server

**AWS Lambda + SSM Parameter Store + Terraform**

A serverless application that serves dynamic HTML content using AWS
Lambda Function URLs and SSM Parameter Store.\
The content can be updated without redeploying the application.

------------------------------------------------------------------------

## Overview

This project demonstrates how to:

-   Serve dynamic HTML content
-   Store configuration externally
-   Avoid application redeployment when content changes
-   Use Infrastructure as Code (IaC) with Terraform

The solution follows a simple and cost-effective serverless
architecture.

------------------------------------------------------------------------

## Architecture

The application uses the following AWS services:

-   AWS Lambda -- Executes the Python function\
-   AWS Systems Manager Parameter Store -- Stores the dynamic string\
-   Lambda Function URLs -- Provides a public HTTPS endpoint\
-   Terraform -- Provisions infrastructure

### Flow Diagram

``` mermaid
flowchart TD
    A[Public Function URL] --> B[Lambda Function]
    B --> |Get Parameter| C[SSM Parameter Store]
```

### How It Works

1.  The user accesses the Lambda Function URL.
2.  The Lambda function retrieves a string from Parameter Store.
3.  The function dynamically builds an HTML response.
4.  The content is returned to the browser.

If the parameter value changes, the next request automatically reflects
the update --- no redeployment required.

------------------------------------------------------------------------

## Lambda Function Code

``` python
import os
import boto3


def get_parameter(name):
    try:
        ssm = boto3.client("ssm")
        response = ssm.get_parameter(Name=name, WithDecryption=False)
        return response["Parameter"]["Value"]
    except Exception:
        return "__DYNAMIC_STRING_NOT_FOUND__"


def lambda_handler(event, context):
    parameter_name = os.getenv("PARAMETER_NAME", "my-parameter")

    value = get_parameter(parameter_name)
    html = f"<h1>The saved string is: {value}</h1>"

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": html,
    }
```

------------------------------------------------------------------------

## IAM Requirements

The Lambda execution role must include:

-   `ssm:GetParameter` permission 
-   Access to the specific parameter ARN

This follows the principle of least privilege.

------------------------------------------------------------------------

## Deployment

### Prerequisites

-   Terraform \>= 1.0
-   AWS CLI \>= 2.0
-   Python 3.9
-   Configured AWS credentials

------------------------------------------------------------------------

### Steps

``` bash
git clone https://github.com/KrlosAren/dynamic-string-challenge.git
cd dynamic-string-challenge

terraform init
terraform plan
terraform apply --auto-approve
```

After deployment:

1.  Copy the generated Function URL from Terraform output.
2.  Open it in your browser.

You should see the dynamic string rendered in HTML.

------------------------------------------------------------------------

## Updating the Dynamic String

To update the content without redeploying:

``` bash
aws ssm put-parameter   --name "/app/dynamic_string"   --value "New Value Here"   --overwrite
```

Refresh the browser --- the new value will be displayed immediately.

------------------------------------------------------------------------

## Cleanup

To destroy all created resources:

``` bash
terraform destroy
```

------------------------------------------------------------------------

## Why This Architecture?

-   Serverless compute (no EC2 management)
-   Externalized configuration
-   No redeployment for content updates
-   Low operational cost
-   Infrastructure as Code

------------------------------------------------------------------------

## Possible Improvements (Production Considerations)

For production environments, consider:

-   Enabling authentication on the Function URL
-   Adding CloudWatch logging and monitoring
-   Implementing caching to reduce SSM calls
-   Restricting access via IAM or API Gateway
