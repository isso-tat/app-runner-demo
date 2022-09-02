terraform {
  required_version = "1.2.5"
  backend "local" {
	path = "./terraform.tfstate"
  }
}