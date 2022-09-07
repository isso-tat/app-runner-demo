variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "image_dir" {
  description = "Target directory name; nginx / laravel / php_apache"
  type = string
  default = "php_apache"
}