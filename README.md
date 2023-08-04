
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
zip -r ./.aws/function.zip index.mjs
```

```shell
# Lamdaテスト
aws lambda invoke \
--function-name my_lambda \
--payload file://event.json \
--cli-binary-format raw-in-base64-out \
output.txt
```