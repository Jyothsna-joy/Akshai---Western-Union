variable "bucket" {
  type        = string
  default     = "akshai-test-lambda"
  description = "bucket name"
}

variable "zip" {
  type    = string
  default = "zip"
}

variable "source_file" {
  type    = string
  default = "getfile.py"
}


variable "output_path" {
  type    = string
  default = "getfile.zip"
}

variable "function_name" {
  type        = string
  default     = "lambda_function_getfile"
  description = "function name of lambda"
}

variable "handler" {
  type        = string
  default     = "getfile.lambda_handler"
  description = "function handler name"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "name" {
  type    = string
  default = "akshai-test"
}

variable "binary_media_types" {
  type    = string
  default = "image/jpeg"
}

variable "endpoint_types" {
  type    = string
  default = "REGIONAL"
}

variable "http_method" {
  type    = string
  default = "GET"
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "integration_http_method" {
  type    = string
  default = "POST"
}
variable "proxy_type" {
  type    = string
  default = "AWS_PROXY"
}

variable "stage_name" {
  type    = string
  default = "development"
}