resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "go-custom-runtime-lambda"  
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}
