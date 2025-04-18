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
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }

  filename = "lambda_function.zip"

  code {
    zip_file = <<EOF
import boto3
import json

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('user_data')
    
    if event['httpMethod'] == 'POST':
        body = json.loads(event['body'])
        user_id = body['user_id']
        user_data = body['user_data']
        
        table.put_item(
            Item={
                'user_id': user_id,
                'user_data': user_data
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps('User added successfully!')
        }
    
    elif event['httpMethod'] == 'GET':
        user_id = event['queryStringParameters']['user_id']
        
        response = table.get_item(
            Key={
                'user_id': user_id
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps(response.get('Item', {}))
        }
EOF
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.user_data_function.arn
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table"
  type        = string
}
