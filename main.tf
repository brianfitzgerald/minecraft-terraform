provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "${var.aws_credentials_location}"
  profile = "${var.profile}"
}

resource "aws_vpc" "main" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = true

  tags {
    Name = "${var.minecraft_tag}"
  }
}

resource "aws_subnet" "main" {
  tags {
    Name = "${var.minecraft_tag}"
  }

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.minecraft_tag}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.minecraft_tag}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_security_group" "allow_all" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft_instance" {
  ami             = "ami-c58c1dd3"
  instance_type   = "t2.micro"

  tags {
    Name = "${var.minecraft_tag}"
  }

  user_data            = "${file("setup.sh")}"
  key_name             = "${var.keypair_name}"

  subnet_id            = "${aws_subnet.main.id}"
  security_groups = ["${aws_security_group.allow_all.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.mc_profile.name}"
}

resource "aws_eip" "mc_ip" {
  vpc = true

  instance = "${aws_instance.minecraft_instance.id}"
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_iam_instance_profile" "mc_profile" {
  name  = "test_profile"
  role = "${aws_iam_role.s3_access.name}"
}

resource "aws_iam_role" "s3_access" {
  name = "s3_access"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
