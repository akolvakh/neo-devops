# ======================
# DYNAMODB STATE LOCKING TABLE
# ======================

resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamodb_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name        = "Terraform Lock Table"
      Purpose     = "terraform-state-locking"
      Environment = var.env_name
    }
  )

  lifecycle {
    # Тимчасово відключено для міграції
    # prevent_destroy = true
  }
}

