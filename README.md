
### Terraformでリソース構築

```shell
# コンテナを立ち上げる
docker run \
  -v ~/.aws:/root/.aws \
  -v $(pwd)/.aws:/terraform \
  -w /terraform \
  -it \
  --entrypoint=ash \
  hashicorp/terraform:1.5

# 初期化
terraform init

# 差分検出
terraform plan

# コードを適用する
terraform apply -auto-approve

# フォーマット
terraform fmt -recursive

# 削除
terraform destroy
```

```shell
# デプロイパッケージを作成
zip ./.aws/function.zip index.mjs
```


```
resource "aws_dynamodb_table" "users" {
  name           = "users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_sqs_queue" "queue" {
  name = "my-queue"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "my_lambda"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = "lambda_function_payload.zip"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn  = aws_sqs_queue.queue.arn
  function_name     = aws_lambda_function.lambda.arn
  enabled           = true
  batch_size        = 5
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "sqs:DeleteMessage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ses_policy" {
  name   = "lambda_ses_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "ses:SendEmail",
        Resource = "*"
      },
    ]
  })
}

resource "aws_ses_email_identity" "email" {
  email = "your-email@example.com"
}

resource "aws_ses_domain_identity" "example" {
  domain = "example.com"
}

```