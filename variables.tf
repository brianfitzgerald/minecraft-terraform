variable "aws_credentials_location" {
  type = "string"
  default = "~/.aws/credentials"
}

variable "profile" {
  type = "string"
  default = "personal"
}

variable "server_name" {
  type = "string"
  default = "briantown"
}

variable "keypair_name" {
  type = "string"
  default = "minecraft_ec2"
}