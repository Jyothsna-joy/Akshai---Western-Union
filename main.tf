
#lambda creation
data "archive_file" "zipit" {

  type = var.zip

  source_file = var.source_file

  output_path = var.output_path

}

resource "aws_lambda_function" "GetfileS3bucket" {
  filename      = var.output_path
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.handler

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.zipit.output_base64sha256

  runtime = var.runtime

}



resource "aws_iam_role" "iam_for_lambda" {
  name = var.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "my-policy" {
  name = var.name
  role = aws_iam_role.iam_for_lambda.id


  # This policy is exclusively available by my-role.
  policy = <<-EOF
 {
   "Version": "2012-10-17",
   "Statement": [
     {
       "Sid": "AccessObject",
       "Effect": "Allow",
       "Action": [
         "s3:*"
       ],
      "Resource": [
        "arn:aws:s3:::${var.bucket}/*"
      ]
     }
   ]
 }
EOF
}

#lambda Permission

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetfileS3bucket.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}


# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name               = var.name
  binary_media_types = [var.binary_media_types]
  endpoint_configuration {
    types = [var.endpoint_types]

  }
}


resource "aws_api_gateway_resource" "resource" {
  path_part   = "{bucket}"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.http_method
  authorization = var.authorization
  request_parameters = {
    "method.request.path.bucket" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = var.integration_http_method
  type                    = var.proxy_type
  uri                     = aws_lambda_function.GetfileS3bucket.invoke_arn
  request_parameters = {
    "integration.request.path.id" = "method.request.path.bucket"
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.method,aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
}