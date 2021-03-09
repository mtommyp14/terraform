terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "tom"
  #   access_key = "ASIAZWVGQS3MELC2NXY7"
  #   secret_key = "Zo6wYPPhqwCgJenSWqLhxPUeAkStAeXFFnVCMjUR"
}


resource "aws_instance" "my-web-serve" {
  ami                    = "ami-0915bcb5fa77e4892" //amazon linux
  instance_type          = "t2.micro"
  key_name               = "terraform-keypair"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = <<EOF
#!/bin.bash
yum -y update
yum -y install httpd
echo "<em style='colour:blue;'> The page are served from: 'hostname-f' </em>" /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "Webserver Built by Terraform"
    owner = "Tommy"
  }
}

variable "vpcid" {
  type    = string
  default = "vpc-b77fcbca"
}

resource "aws_security_group" "web" {
  name        = "Terraform-Sg"
  description = "Security Group for my Terraform"
  vpc_id      = "{var.vpcid}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow port HTTP"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow port HTTPS"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All Port"
  }

  tags = {
    Name  = "Webserver SG"
    owner = "Tommy"
  }
}
