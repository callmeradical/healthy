variable "region" {
  default = "us-east-1"
}

variable "instances" {}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "ecs_cluster" {
  type = "string"
}

variable "etcd_token" {
  type = "string"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-1298.6.0-hvm"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

data "template_file" "user_data" {
  template = "${file("${path.module}/data/user_data")}"

  vars {
    etcd_token   = "${var.etcd_token}"
    cluster_name = "${var.ecs_cluster}"
  }
}

resource "aws_instance" "node" {
  count                       = "${var.instances}"
  ami                         = "${data.aws_ami.coreos.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(var.subnets,count.index)}"
  associate_public_ip_address = true
  security_groups             = ["${var.security_groups}"]

  tags {
    Name      = "ECS Node ${count.index}"
    Terraform = true
  }
}
