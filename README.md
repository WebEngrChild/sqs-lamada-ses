## Lamda

```shell
# 更新
aws lambda update-function-code \
    --function-name ses_email_sender \
    --zip-file fileb://.aws/ses_email_sender.zip
```

### Node.js（Sending Email）

```shell
# デプロイパッケージを作成
zip -r ./.aws/lamda/ses_email_sender.zip index.mjs
```

### Go（Sending SQS with Data from DynamoDB）

```shell
# デプロイパッケージを作成
GOOS=linux GOARCH=amd64 go build -o main
zip -r ./.aws/lamda/sqs_sender.zip main
```

## Terraform

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

## DynamoDB

```shell
# テスト用レコード作成
aws dynamodb put-item \
    --table-name users \
    --item '{
        "user_id": {"S": "1"},
        "timestamp": {"S": "2023-08-03T10:00:00Z"},
        "status": {"S": "a"},
        "mailAddress": {"S": "factor_9mmplusfact@yahoo.co.jp"},
        "name": {"S": "Jone"}
    }' \
    --region ap-northeast-1
```