## Lamda

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

#### ECRへカスタムランタイムデプロイ

```shell
docker build --platform linux/amd64 -t go-custom-runtime-lambda .

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com

docker tag go-custom-runtime-lambda:latest xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/go-custom-runtime-lambda:latest

docker push xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/go-custom-runtime-lambda:latest
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
        "mailAddress": {"S": "<ご自身のメールアドレスを入力>"},
        "name": {"S": "Jone"}
    }' \
    --region ap-northeast-1
```