
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

## Lamda

### Node.js（Sending Email）

```shell
# デプロイパッケージを作成
zip -r ./.aws/ses_email_sender.zip index.mjs
```

```shell
# 更新
aws lambda update-function-code \
    --function-name ses_email_sender \
    --zip-file fileb://.aws/ses_email_sender.zip
```

```shell
# テスト
aws lambda invoke \
--function-name ses_email_sender \
--payload file://event.json \
--cli-binary-format raw-in-base64-out \
output.txt
```

### Go（Sending SQS with Data from DynamoDB）

```shell
# Goのセットアップ
go mod init
go mod tidy
```

```shell
# ビルド
GOOS=linux GOARCH=amd64 go build -o main
```

```shell
# デプロイパッケージを作成
zip -r ./.aws/sqs_sender.zip main
```