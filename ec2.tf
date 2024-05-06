terraform {
  required_version = ">=1.6.0" # Versão do Terraform

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key


  default_tags {
    tags = {
      owner      = "Holanda"
      managed-by = "Terraform134"
    }
  }
}

resource "aws_instance" "terraform" {
  ami                         = "ami-058bd2d568351da34" # Debian 
  instance_type               = "t2.micro"
  key_name                    = "Terrakey" # Não esqueca de gerar a chave  pública e privada para este nome!
  associate_public_ip_address = true


}
