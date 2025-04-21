rule "aws_lambda_function_runtime_allowed" {
  enabled = true
  severity = "warning"
  terraform {
    resource "aws_lambda_function" "lambda_func" {
      runtime in ["nodejs18.x", "python3.8", "java17"]
    }
  }
  message = "Lambda function '${resource.aws_lambda_function.lambda_func.name}' uses an unsupported runtime. Allowed runtimes are: nodejs18.x, python3.11, java17."
}
