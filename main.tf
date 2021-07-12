provider "aws" {
  region = "ca-central-1"
  access_key = "AKIAVWUN5TJ544FJE2KT"
  secret_key = "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"
}

//variable "subnet_prefix" {
//  description = "cidr block for the subnet"
//}

resource "aws_vpc" "webserver-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames= true
  tags = {
    Name = "WebServer"
  }
}

#Create the Internet Gateway for public Access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webserver-vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.webserver-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "webserver_subnet1"
  }
}

#Create the route tables
resource "aws_route_table" "webserver-route-table" {
  vpc_id = aws_vpc.webserver-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "webserver route table"
  }
}

#Associate subnets with Route Table
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.webserver-route-table.id
}

#Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name = "allow_web"
  description = "Allow Public Web inbound traffic"
  vpc_id = aws_vpc.webserver-vpc.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# the ELB over HTTP
resource "aws_security_group" "elb" {
  name        = "elb_sg"
  description = "Used in the terraform"

  vpc_id = aws_vpc.webserver-vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.igw"]
}

# Create a subnet to launch our instances into
resource "aws_elb" "elbWeb" {
  name = "elb"
  subnets = [aws_subnet.subnet-1.id]
  security_groups = [aws_security_group.elb.id]
  //instances = [aws_instance.web_server_instance.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}

//resource "aws_key_pair" "my-key" {
//  key_name = "my-key"
//  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCFk5r9ZHrdeyIwMr+UL4m34SbsP5vItImPB947I+8L/ZJv6h0XgBkGvVODoJ/uSo3is1z0LkKvPR7nb/wq9lUdGFYKS0cCksK5bwv/WvvNbdvF9ZzRAfFWtUe3AHoxpGtW9jC5AroMDu3UVsGHLrT8AxxaNbYRcVEiK9lboet6Ri3hA5d1OBlFZrLbfXY1EwmBd5McCclNecKQQVjNRQWK0C1BnRtM3OaUHVlKShQzR+1kuPgwTnDog4aSDsZBiXQ57FDC5tBRlmDSoj/fWit9pPps1B5VP8jf3uLvNhG+nj8derWcU39oBdagGgGe2WAF0j8yt1dlUXtkYZQ7PIj5"
//}

  #Create a network interface with an ip in the subnet that was created in step 4
//resource "aws_network_interface" "webserver-nic" {
//   subnet_id       = aws_subnet.subnet-1.id
//   private_ips     = ["10.0.1.50"]
//   security_groups = [aws_security_group.allow_web.id]
//
// }

#  Assign an elastic IP to the network interface created

//resource "aws_eip" "eip" {
//   vpc                       = true
//   network_interface         = aws_network_interface.webserver-nic.id
//   associate_with_private_ip = "10.0.1.50"
//  depends_on                = [aws_internet_gateway.igw]
// }


#Create Ubuntu server and install/enable nginx
resource "aws_instance" "web_server_instance" {
  ami = "ami-0db72f413fc1ddb2a"
  instance_type = "t2.nano"
  availability_zone = "ca-central-1a"
  subnet_id = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name          = "my-key"
  associate_public_ip_address = true

  //     network_interface {
//       device_index         = 0
//       network_interface_id = aws_network_interface.webserver-nic.id
//     }
//  connection {
//    # The default username for our AMI
//    user = "ubuntu"
//  }
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 amazon-linux-extras install nginx1 -y
                 sudo service nginx start
                 EOF
 // user_data = file("./entrypoint.sh")
  tags = {
    Name = "nginx-instance",
  }
}

output "server_private_ip" {
   value = aws_instance.web_server_instance.private_ip

 }
output "server_id" {
   value = aws_instance.web_server_instance.id
 }

//output "address" {
//  value = aws_eip.eip.public_ip
//}