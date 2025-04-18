resource "aws_dynamodb_table" "user_data" {
  name           = "user_data"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

output "table_name" {
  value = aws_dynamodb_table.user_data.name
}
