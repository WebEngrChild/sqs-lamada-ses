/*
SES
*/

resource "aws_lambda_function" "ses_email_sender" {
  function_name = "ses_email_sender"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role_for_ses.arn
  filename      = "lamda/ses_email_sender.zip"
  environment {
    variables = {
      EMAIL_SOURCE = var.your_email
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.ses_email_sender.arn
  batch_size       = 10
}

resource "aws_iam_role" "lambda_role_for_ses" {
  name = "lambda_role_for_ses"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy_for_ses" {
  name = "lambda_policy_for_ses"
  role = aws_iam_role.lambda_role_for_ses.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
        ],
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*"
      },
    ]
  })
}

/*
SQS
*/

resource "aws_lambda_function" "sqs_sender" {
  function_name = "sqs_sender"
  handler       = "main"
  runtime       = "go1.x"
  role          = aws_iam_role.lambda_role_for_sqs.arn
  filename      = "lamda/sqs_sender.zip"
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.queue.url
    }
  }
}

# LambdaのIAMロール
resource "aws_iam_role" "lambda_role_for_sqs" {
  name = "lambda_role_for_sqs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# LambdaのIAMポリシー
resource "aws_iam_role_policy" "lambda_policy_for_sqs" {
  name = "lambda_policy_for_sqs"
  role = aws_iam_role.lambda_role_for_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem"
        ],
        Resource = aws_dynamodb_table.users.arn
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
        ],
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*"
      },
    ]
  })
}