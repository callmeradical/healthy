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

data "aws_iam_policy_document" "assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_nodes" {
  statement {
    sid = "1"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs" {
  name   = "ecsnodes"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_nodes.json}"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name  = "ecs_nodes_profile"
  roles = ["${aws_iam_role.ecsrole.name}"]
}

resource "aws_iam_role" "ecsrole" {
  name = "ecs_nodes_role"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

resource "aws_iam_role_policy_attachment" "ecsrole" {
  role       = "${aws_iam_role.ecsrole.name}"
  policy_arn = "${aws_iam_policy.ecs.arn}"
}

resource "aws_instance" "node" {
  count                       = "${var.instances}"
  ami                         = "${data.aws_ami.coreos.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(var.subnets,count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${var.security_groups}"]
  user_data                   = "${data.template_file.user_data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_profile.name}"
  key_name                    = "aws1"

  tags {
    Name      = "ECS Node ${count.index}"
    Terraform = true
  }
}
