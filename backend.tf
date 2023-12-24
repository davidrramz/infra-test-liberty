resource "aws_s3_bucket" "bucket-state" {
  bucket = join("-", [local.solution_name, "s3", "terraform-state", "bucket"])

  tags = {
    Name = join("-", [local.solution_name, "s3", "terraform-state", "bucket"])
  }
}

resource "aws_s3_bucket_versioning" "bucket-state" {
  bucket = aws_s3_bucket.bucket-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-state" {
  bucket = aws_s3_bucket.bucket-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_dynamodb_table" "bucket-state" {
  name = join("-", [local.solution_name, "dynamoDB", "terraform-state", "table"])
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}