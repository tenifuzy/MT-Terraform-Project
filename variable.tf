variable "public_key_path" {
  description = "Path to the public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBgnV+Yv4J1sixpXhQLGUD1JSURZDy2CASJjufCbRwZ6ji6Ofz4MOInf9dhsAb5y678A/v8swJu0UM9qe1hg+AmLf3V0iYUiw9ku0sJ/Ewb0Kj8e3CXs4Fz4Dj+vIYMSHnr/Jof7ukwTTHvVoIa4nlDq44rKzGWpBMwr7llN6+Om6Pz6jjjz8Jhx7EqWGbXnhPXo6E7EaZm+3+S3o9uxJQb56Qcoe8lOql+7YpnM5BvVy3gOb6mvyGu5LbCWnvUV9O8RzS0CjYROpa9GzFC2ZID9GNuBfxlhv17B+lF9LUKetOou2Af/TxtTNcaTm8SgwrCxspAkK6HDNIk8sKtYXjt8dpGg4nsWb6sc1P9Q4/om52qZlPXkD4z+g9xKSz4UuLjvR7eHefN+lJl6LPCpkHNzVFT9ApzEm2FLIxBNMPB69zrQ3O1g8Ak+2/+tEntfTNmrHbkoUSEeOjL0F7OervAzs4C33kQP6Qtr5z5MirMe1ex8M/BaVEAqYAKsfRDh0= tenif@TENIOLA"
}
variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"

}

variable "public_cidr_block" {
  description = "Public CIDR block"
  default     = "10.0.1.0/24"

}


variable "private_cidr_block" {
  description = "Private CIDR block"
  default     = "10.0.2.0/24"

}

variable "availability_zone" {
  description = "path to availablility zone"
  default     = "us-east-1a"

}

variable "region" {
  description = "path to region"
  default     = "us-east-1"
}


variable "instance" {
  description = "instance type"
  default     = "t2.micro"
}

variable "aws_ami" {
  description = "ami type"
  default     = "ami-0e86e20dae9224db8"
}