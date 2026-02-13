
provider "aws" {
  region = "us-east-2"
}

resource "aws_ssm_parameter" "dynamic_string" {
  name  = "/app/dynamic_string"
  type  = "String"
  value = "__DYNAMIC_STRING__"
}

resource "aws_cloudwatch_log_group" "dynamic_string" {
  name = "/aws/lambda/dynamic_lambda_function"
  retention_in_days = 7

}

data "archive_file" "dynamic_string" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]

  }
}

data "aws_iam_policy_document" "ssm_parameter_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory"
    ]
    resources = [aws_ssm_parameter.dynamic_string.arn]
  }

}

resource "aws_iam_role" "dynamic_string_role" {
  name               = "dynamic_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

}

resource "aws_iam_role_policy" "ssm_parameter_policy" {
  policy = data.aws_iam_policy_document.ssm_parameter_permissions.json
  role   = aws_iam_role.dynamic_string_role.id
}

resource "aws_lambda_function" "dynamic_func" {
  filename      = data.archive_file.dynamic_string.output_path
  function_name = "dynamic_lambda_function"

  role = aws_iam_role.dynamic_string_role.arn

  handler     = "handler.lambda_handler"
  runtime     = "python3.12"
  code_sha256 = data.archive_file.dynamic_string.output_base64sha256

  logging_config {
    log_format = "JSON"
    application_log_level = "INFO"
    system_log_level = "WARN"
  }

  environment {
    variables = {
      PARAMETER_NAME = aws_ssm_parameter.dynamic_string.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.dynamic_string]

}


resource "aws_lambda_function_url" "dynamic_string" {
  function_name      = aws_lambda_function.dynamic_func.function_name
  authorization_type = "NONE"
}


output "fun_uri" {
  value = aws_lambda_function_url.dynamic_string.function_url
}