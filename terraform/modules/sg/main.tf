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


resource "aws_security_group_rule" "all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg1.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
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
