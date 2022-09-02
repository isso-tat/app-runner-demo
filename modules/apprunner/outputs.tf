output "service_arn" {
  value = aws_apprunner_service.default_service.arn
}

output "app_runner_url" {
  value = aws_apprunner_service.default_service.service_url
}

output "application_log_group_arn" {
  value = data.aws_cloudwatch_log_group.application_log_group.arn
}

output "application_log_group_name" {
  value = data.aws_cloudwatch_log_group.application_log_group.name
}

output "service_log_group_arn" {
  value = data.aws_cloudwatch_log_group.service_log_group.arn
}