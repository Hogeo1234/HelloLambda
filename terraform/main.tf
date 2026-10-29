provider "aws" {
  region = "ap-northeast-1"
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "HelloLambda"
}

# Create IAM role for Lambda
data "aws_iam_role" "existing_lambda" {
  name = "${var.lambda_name}-role"
}

resource "aws_iam_role" "lambda_exec" {
  count = data.aws_iam_role.existing_lambda.name == "" ? 1 : 0
  # ... rest of config
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "../project/src/hello_lambda.zip"
}

# Create Lambda function from zip created in CI/CD
resource "aws_lambda_function" "hello" {
  filename         = var.lambda_zip_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "hello_lambda.handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_zip_path)
}
