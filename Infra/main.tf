provider "aws" {
  region = var.region
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source = "./modules/lambda"
  dynamodb_table = module.dynamodb.table_name
}

module "api_gateway" {
  source = "./modules/api_gateway"
  lambda_function_arn = module.lambda.lambda_function_arn
  region = var.region
}

variable "region" {
  description = "The AWS region"
  default     = "us-west-2"
}
