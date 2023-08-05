## Node Lamda (Sending Email)

```shell
# テスト
aws lambda invoke \
--function-name ses_email_sender \
--payload file://event.json \
--cli-binary-format raw-in-base64-out \
output.txt
```

```json
{
  "Records": [
    {
      "body": "{\"email\": \"example@example.com\", \"name\": \"John\"}"
    }
  ]
}
```

```shell
# 更新
aws lambda update-function-code \
    --function-name ses_email_sender \
    --zip-file fileb://.aws/ses_email_sender.zip
```

## Go Lamda (Sending SQS with Data from DynamoDBS)

```shell
# テスト
aws lambda invoke \
--function-name sqs_sender \
output.txt
```

```shell
# 更新
aws lambda update-function-code \
    --function-name sqs_sender \
    --zip-file fileb://.aws/sqs_sender.zip
```