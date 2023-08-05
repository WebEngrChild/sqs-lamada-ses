# EventBridgeルールの作成
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every-minute"
  schedule_expression = "rate(1 minute)"
}

# EventBridgeルールに対するターゲットの作成
resource "aws_cloudwatch_event_target" "run_lambda_every_minute" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "runLambdaFunction"
  arn       = aws_lambda_function.sqs_sender.arn
}

# ターゲットとなるLambda関数に対する実行権限の付与
resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqs_sender.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}
