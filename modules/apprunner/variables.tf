variable "service_name" {
  description = "AppRunner service name."
  type        = string
  default     = "app_runner_service"
}

variable "max_concurrency" {
  description = "The maximal number of concurrent requests that you want an insance to process. [1, 200]"
  type        = number
  default     = 100
}

variable "max_size" {
  description = "The maximal number of instances provisioned for your service. [1, 25]"
  type        = number
  default     = 25
}

variable "min_size" {
  description = "The minimal number of instances provisioned for your service. [1, 25]"
  type        = number
  default     = 1
}

variable "apprunner_cpu" {
  description = "CPU size for each instance of App Runner service."
  type        = string
  default     = "1024"
}

variable "apprunner_memory" {
  description = "Memory size (MB/GB) for each instance of App Runner service."
  type        = string
  default     = "2048"
}

variable "runtime_environment_variables" {
  description = "Environment varialbles in runtime."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_url" {
  description = "ECR Repository url"
  type        = string
}

variable "subnet_ids" {
  description = "A list of IDs of subnets that App Runner should use when it associates your service with a custom Amazon VPC. Should be at least 3."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "A list of IDs of security groups that App Runner should use for access to AWS resources under the specified subnets."
  type        = list(string)
  default     = []
}