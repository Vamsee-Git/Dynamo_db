resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "user_data_function" {
  function_name = "user_data_function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda_function.py")

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.user_data_function.arn
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table"
  type        = string
}
