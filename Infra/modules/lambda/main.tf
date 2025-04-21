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
resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_policy"
  description = "Policy to allow Lambda function to access DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:us-west-2:877786395093:table/user_data"
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy to allow Lambda function to be invoked"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "arn:aws:lambda:us-west-2:877786395093:function:user_data_function"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
resource "aws_lambda_function" "user_data_function" {
  function_name = "user_data_function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 10
  tracing_config{
    mode= "Active"
  }
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }

  filename = "lambda_function.zip"
}

output "lambda_function_arn" {
  value = aws_lambda_function.user_data_function.arn
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table"
  type        = string
}
