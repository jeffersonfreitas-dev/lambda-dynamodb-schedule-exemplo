provider "aws" {
  region = var.region
}

resource "aws_dynamodb_table" "cache-token_table" {
    name =          "cache-token_table"
    billing_mode =  "PAY_PER_REQUEST"
    hash_key =      "id"

    attribute {
      name = "id"
      type = "S"
    }

    ttl {
      attribute_name = "expires_at"
      enabled = true
    }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_dynamodb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role          = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role          = aws_iam_role.lambda_exec_role.name
  policy_arn    = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda"
    output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "generate_token" {
  function_name     = "generate_token"
  handler           = "app.lambda_handler"
  runtime           = "python3.11"
  filename          = data.archive_file.lambda_zip.output_path
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  role              = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      AWS_REGION_JEFF   = var.region,
      SNS_TOPIC_ARN     = aws_sns_topic.token_notifications.arn 
    }
  }
}


#EVENT BRIDGE
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "invoke-generate-token-daily"
  description         = "Dispara a Lambda diariamente às 18h UTC"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "generate_token_lambda"
  arn       = aws_lambda_function.generate_token.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_token.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}


#SNS TOPIC
resource "aws_sns_topic" "token_notifications" {
  name = "token-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.token_notifications.arn
  protocol  = "email"
  endpoint  = "jefferson.dev21@gmail.com"
}


#Permissão para Lambda publicar no SNS
resource "aws_iam_policy" "lambda_publish_sns" {
  name = "lambda-publish-sns-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sns:Publish",
      Resource = aws_sns_topic.token_notifications.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_publish_sns_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_publish_sns.arn
}