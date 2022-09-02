resource "aws_apprunner_auto_scaling_configuration_version" "scaling_config" {
  auto_scaling_configuration_name = "${var.service_name}_scale"

  max_concurrency = var.max_concurrency
  max_size        = var.max_size
  min_size        = var.min_size

  tags = {
    Name = "AppRunnerScalingConfig"
  }
}

resource "aws_apprunner_service" "default_service" {
  service_name = var.service_name

  instance_configuration {
    cpu               = var.apprunner_cpu
    memory            = var.apprunner_memory
    instance_role_arn = aws_iam_role.apprunner_instance_iam.arn
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.ecr_access_role.arn
    }

    image_repository {
      image_configuration {
        port                          = 80
        runtime_environment_variables = var.runtime_environment_variables
      }

      image_identifier      = "${var.ecr_repository_url}:latest"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = true
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }

  tags = {
    Name = "AppRunnerService"
  }
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "${var.service_name}_connector"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
  tags = {
    Name = "AppRunnerVPCConnector"
  }
}

data "aws_iam_policy_document" "assume_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecr_access_role" {
  name               = "AppRunnerAccessRoleToECR"
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "apprunner_instance_iam_assume_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "apprunner_instance_vpc_connect_policy" {
  name        = "AppRunnerVPCConnectPolicy"
  description = "VPC Connect IAM policy for AppRunner instance."
  policy      = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds-db:connect"
            ],
            "Resource": [
                "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:*/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "apprunner_instance_iam" {
  name               = "AppRunnerInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.apprunner_instance_iam_assume_document.json
}

resource "aws_iam_role_policy_attachment" "apprunner_instance_iam_vpc_connect_attachment" {
  role       = aws_iam_role.apprunner_instance_iam.name
  policy_arn = aws_iam_policy.apprunner_instance_vpc_connect_policy.arn
}

data "aws_cloudwatch_log_group" "application_log_group" {
  name = "/aws/apprunner/app_runner_service/${aws_apprunner_service.default_service.service_id}/application"
}

data "aws_cloudwatch_log_group" "service_log_group" {
  name = "/aws/apprunner/app_runner_service/${aws_apprunner_service.default_service.service_id}/service"
}