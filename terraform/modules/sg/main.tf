variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type = "string"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "sg1" {
  vpc_id = "${var.vpc_id}"

  tags {
    Terraform = true
    Name      = "ecs-workshop-coreos"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "etcd1" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2379
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "etcd2" {
  type              = "ingress"
  from_port         = 2380
  to_port           = 2380
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "etcd3" {
  type              = "ingress"
  from_port         = 4001
  to_port           = 4001
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "etcd4" {
  type              = "ingress"
  from_port         = 7001
  to_port           = 7001
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "etcd5" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg1.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "sg1_id" {
  value = "${aws_security_group.sg1.id}"
}
