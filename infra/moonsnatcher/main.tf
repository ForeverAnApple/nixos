terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "nixos-dev"
  default_tags {
    tags = { Name = "moonsnatcher", ManagedBy = "opentofu" }
  }
}

variable "ssh_cidr" { type = string }
variable "public_key_path" { type = string }
variable "instance_type" {
  type    = string
  default = "m8a.12xlarge"
}
variable "bootstrap_ssh" {
  type    = bool
  default = false
}

data "aws_vpc" "default" { default = true }
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-west-2a"
  default_for_az    = true
}

resource "aws_key_pair" "moonsnatcher" {
  key_name   = "moonsnatcher"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "moonsnatcher" {
  name   = "moonsnatcher"
  vpc_id = data.aws_vpc.default.id
  dynamic "ingress" {
    for_each = var.bootstrap_ssh ? [22, 22022] : []
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.ssh_cidr]
    }
  }
  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "moonsnatcher" {
  ami                         = "ami-0d943f5462ccb3ad8"
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.moonsnatcher.id]
  key_name                    = aws_key_pair.moonsnatcher.key_name
  disable_api_termination     = true
  associate_public_ip_address = true
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 2048
    iops                  = 6000
    throughput            = 500
    encrypted             = true
    delete_on_termination = false
    tags                  = { Name = "moonsnatcher", ManagedBy = "opentofu" }
  }
  lifecycle { prevent_destroy = true }
}

resource "aws_eip" "moonsnatcher" {
  domain   = "vpc"
  instance = aws_instance.moonsnatcher.id
}

output "instance_id" { value = aws_instance.moonsnatcher.id }
output "public_ip" { value = aws_eip.moonsnatcher.public_ip }
output "security_group_id" { value = aws_security_group.moonsnatcher.id }
