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
  security_groups = ["${aws_security_group.allow_all.id}"]

  tags {
    Name = "${var.minecraft_tag}"
  }

  user_data            = "${file("setup.sh")}"
  key_name             = "Terraformkey"
  depends_on           = ["aws_internet_gateway.gw"]
  subnet_id            = "${aws_subnet.main.id}"
  iam_instance_profile = "s3"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.minecraft_instance.id}"
  allocation_id = "eipalloc-94ce0aa4"
}