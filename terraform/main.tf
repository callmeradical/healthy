terraform {
  backend "s3" {
    bucket = "2wtfstate"
    key    = "md-workshop"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Let's Create a VPC
resource "aws_vpc" "ecs_demo" {
  cidr_block           = "192.168.76.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Terraform = true
    Name      = "ecs-workshop"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.ecs_demo.id}"

  tags {
    Terraform = true
  }
}

resource "aws_route" "internet" {
  route_table_id         = "${aws_vpc.ecs_demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_subnet" "primary" {
  vpc_id            = "${aws_vpc.ecs_demo.id}"
  cidr_block        = "192.168.76.0/24"
  availability_zone = "us-east-1a"

  tags {
    Terraform = true
    Name      = "ecs-workshop"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id            = "${aws_vpc.ecs_demo.id}"
  cidr_block        = "192.168.77.0/24"
  availability_zone = "us-east-1b"

  tags {
    Terraform = true
    Name      = "ecs-workshop"
  }
}

resource "aws_subnet" "tertiary" {
  vpc_id            = "${aws_vpc.ecs_demo.id}"
  cidr_block        = "192.168.78.0/24"
  availability_zone = "us-east-1c"

  tags {
    Terraform = true
    Name      = "ecs-workshop"
  }
}


resource "aws_ecs_cluster" "demo" {
  name = "workshop_demo"
}

module "sg1" {
  source = "modules/sg"
  vpc_id = "${aws_vpc.ecs_demo.id}"
}

module "instances" {
  source = "modules/ec2"

  instances       = 3
  etcd_token      = "056fca74d23fe16bdccee7bf52c65bc2"
  ecs_cluster     = "${aws_ecs_cluster.demo.name}"
  security_groups = ["${module.sg1.sg1_id}"]

  subnets = [
    "${aws_subnet.primary.id}",
    "${aws_subnet.secondary.id}",
    "${aws_subnet.tertiary.id}",
  ]
}
