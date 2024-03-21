// TF for My API Gateway and My Lambda Function

resource "aws_s3_bucket" "lambda_function_bucket" {
  bucket = "natest-lambda-function"
  tags = {
    Environment = "Excercise"
  }
}

resource "aws_s3_bucket" "other_bucket" {
  provider = aws.other
  bucket   = "natest-other-destination"
  tags = {
    Environment = "Excercise"
  }
}

data "archive_file" "lambda_my_function_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda_code.zip"
}

resource "aws_s3_object" "lambda_my_function_code" {
  bucket = aws_s3_bucket.lambda_function_bucket.id
  key    = "lambda_code.zip"
  source = data.archive_file.lambda_my_function_code.output_path
  etag   = filemd5(data.archive_file.lambda_my_function_code.output_path)
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_other_bucket_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::natest-other-destination/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_other_bucket_policy" {
  name        = "other-bucket-policy"
  description = "Policy to access other bucket in other account"
  policy      = data.aws_iam_policy_document.lambda_other_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-other-policy-attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_other_bucket_policy.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

/*
data "aws_iam_policy_document" "lambda_other_bucket_policy" {
  bucket = aws_s3_bucket.other_bucket.id
  policy = data.aws_iam_policy_document.other_bucket_policy.json
}
*/

data "aws_iam_policy_document" "other_bucket_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::natest-other-destination/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::891377300859:role/iam_for_lambda"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  provider = aws.other
  bucket   = aws_s3_bucket.other_bucket.id
  policy   = data.aws_iam_policy_document.other_bucket_policy.json
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "MyFunction"
  s3_bucket     = aws_s3_bucket.lambda_function_bucket.id
  s3_key        = aws_s3_object.lambda_my_function_code.key

  role    = aws_iam_role.iam_for_lambda.arn
  handler = "lambda_code.lambda_handler"

  source_code_hash = data.archive_file.lambda_my_function_code.output_base64sha256

  runtime = "python3.12"
  timeout = 10
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyLambdaFunctionAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.my_lambda_gateway.execution_arn}/*"
}
