provider "aws" {
  region = "ap-northeast-1"
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "HelloLambda"
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = { Service = "lambda.amazonaws.com" },
        Effect = "Allow"
      }
    ]
  })

  lifecycle {
    ignore_changes = [assume_role_policy]
  }
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
