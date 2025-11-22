terraform {
  backend "s3" {
    bucket         = "lesson-5-dev-tfstate-190403256762"
    key            = "l-7-dev/terraform.tfstate" # Отдельный ключ для l-7
    region         = "us-east-1"
    dynamodb_table = "lesson-5-dev-terraform-locks"
    encrypt        = true
  }
}
