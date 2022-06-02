output "bucket_name" {
  value = aws_iam_role_policy.my-policy.policy
}


output "image_url" {
  value = aws_api_gateway_stage.example.invoke_url
}