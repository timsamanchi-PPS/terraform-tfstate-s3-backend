terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}
provider "aws" {
    region = "eu-west-2"
}
# create S3 bucket to store tfstate file
# acl: private
# versioning: enabled
# encryption: enabled
resource "aws_s3_bucket" "codepipeline-tfstate-backend" {
    bucket = "codepipeline-tfstate-backend-01"
    tags = {
      Name = "codepipeline-tfstate-backend"
    }
}
resource "aws_s3_bucket_acl" "tfstate-acl" {
    bucket = aws_s3_bucket.codepipeline-tfstate-backend.id
    acl = "private"
}
resource "aws_s3_bucket_versioning" "tfstate-versioning" {
    bucket = aws_s3_bucket.codepipeline-tfstate-backend.id
    versioning_configuration {
      status = "Enabled" 
    }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate-encryption" {
    bucket = aws_s3_bucket.codepipeline-tfstate-backend.id
    rule {
      apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
      }
    }
}
# create dynamoDB for tfstate locking
resource "aws_dynamodb_table" "tfstate-locking-DB" {
    name = "tfstate-locking-DB"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}

