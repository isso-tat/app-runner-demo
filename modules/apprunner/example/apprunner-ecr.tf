/*
* ECR
*/
resource "aws_ecr_repository" "default" {
  name = "app-runner-demo-repo"
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.default.name

  policy = <<EOF
{
	"rules": [
		{
			"rulePriority": 1,
			"description": "Expire images older than 1 days.",
			"selection": {
				"tagStatus": "untagged",
				"countType": "sinceImagePushed",
				"countUnit": "days",
				"countNumber": 1
			},
			"action": {
				"type": "expire"
			}
		}
	]
}
EOF
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "$(aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.default.repository_url})"
  }

  provisioner "local-exec" {
    command = "docker build -t app-runner-demo ./nginx"
  }

  provisioner "local-exec" {
    command = "docker tag app-runner-demo:latest ${aws_ecr_repository.default.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.default.repository_url}:latest"
  }
}

/*
* App Runner
*/
module "apprunner_service" {
  source = "../"

  max_concurrency = 30
  max_size        = 3
  min_size        = 1

  ecr_repository_url = aws_ecr_repository.default.repository_url
  apprunner_cpu      = "1024"
  apprunner_memory   = "2048"

  runtime_environment_variables = {}

  subnet_ids         = [aws_subnet.server_subnet.id, aws_subnet.server_subnet2.id, aws_subnet.server_subnet3.id]
  security_group_ids = [aws_security_group.server_sg.id]
}