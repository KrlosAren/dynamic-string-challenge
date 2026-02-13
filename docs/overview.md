# Dynamic String Challenge – Solution Explanation

## Solution Overview and Available options

For this challenge, I evaluate three different architectural approaches:

1. EC2 + NGIX: Deploying an EC2 instance running Nginx and using query parameters to dynamically render content. This approach requires server management, patching, and higher operational overhead. Additionally, the URL behavior would not fully match the challenge requirements.
2. AWS Lambda + Parameter Store (Chosen Solution): Using a Lambda Function URL to serve HTML content dynamically and AWS System Manager Parameter Store to store the string. This approach avoids server management and allows updating the content without redeployment
3. S3 + Lambda: Storing the content inside an S3 bucket (e.g. JSON File) and using lambda to retrieve and parse it. While valid, this introduces more operational overhead compared to Parameter Store for simple configuration storage.

## Reasons behind the chosen architecture

I selected the Lambda + Parameter Store approach because:

- It is serverless and requires no infrastructure management
- It minimizes operational overhead
- It is cost-effective
- It allows updating the string with a simple CLI command
- It follows cloud-native best practices by externalizing configuration

## Future improvements

If I had more time, I would enhance the solution by:

1. Reducing call to Parameter Store using in-memory caching (warm start) or Lambda Extensions to improve performance and reduce latency
2. Adding authentication to secure public endpoint
3. Introducing API Gateway to manage throttling, rate limiting, monitoring, and custom domain support
4. Adding monitoring and observability using CloudWatch metrics and logs
