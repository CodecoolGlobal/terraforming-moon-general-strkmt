provider "aws" {
  region  = "eu-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "vvppcc"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id =  aws_vpc.vpc.id
  cidr_block = "11.0.0.0/24"
  tags = {
    Name = "pbsn"
   }
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0000d2f2c5c71dacd"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  key_name               = "id_rsa"
  tags = {
    Name = "ec2"
  }
}

resource "aws_key_pair" "keykey" {
  key_name = "id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoyjOHs+MSTJahfxT3tiyX5HA5X4KP3jncszqTndMp3iyXCXWpb/YP6ug8hSmTnP76cHVceZAMRHJs3LF5BYKG2LiEkzNiq/ptd78wuJ0NeCMVMImf3qMzuHVv45ydKSftsWc2w2fSKx8a1GMptDHAHHjpz75M7m+UH4xAKkZvX9ptrE+AuW0i7IfTYqFRZmiaycCCJ7cRpi13N7cY7lFQJcEgifcsIaTaB3L8mQ5zWtYtVnBTgq1kbzS7k30u1LYWCI1Zb0JfFm2gc1YgLS8usET97cS57zUcWmyToKQQXd3E7IMjHVRecKaI0DkA+gkaB1nf1s/KahranquZwnkMcj1IgbJyVAznXQ+gqsvbV51Y8Pt9vACIvvEkYPVU7yMdhV8fz490AGru9R0XXVwRmLf969/KjI5DE9wBR+a/Wntcv/l/kKW6RoPH3eh1EIAU/+i4age1cq+/jAAIJ2kcQivqjj/AQD++N/fSt5fwnBjrskmoMFhq9XhSHOVaTJ0= strkmt@strkmt-ThinkPad-T430s"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  name = "SSH Access"
  description = "SSH on port 22"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH Access"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH security group"
  }
}