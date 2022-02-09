# Create a VPC
resource "aws_vpc" "hello-world-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
       Name = "hello-world-vpc"
  }
}

# Attach a Internet gateway
resource "aws_internet_gateway" "hello-world-igw" {
  vpc_id = "${aws_vpc.hello-world-vpc.id}"

  tags = {
      Name = "hello-world-igw"
  }
}

# Create public subnet in us-east-1a AZ
resource "aws_subnet" "hello-world-subnet-public-1" {
  vpc_id                  = "${aws_vpc.hello-world-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
       Name = "hello-world-subnet-public-1"
  }
}

# Create Route table

resource "aws_route_table" "hello-world-public-rt" {
    vpc_id = "${aws_vpc.hello-world-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.hello-world-igw.id}"
    }

    tags = {
       Name = "hello-world-public-rt"
    }
}

# Create RTA

resource "aws_route_table_association" "hello-world-rta-public-1" {
    subnet_id = "${aws_subnet.hello-world-subnet-public-1.id}"
    route_table_id = "${aws_route_table.hello-world-public-rt.id}"

}

# Create Security Group

resource "aws_security_group" "hello-world-sg" {
    name = "hello-world-sg"
    vpc_id = "${aws_vpc.hello-world-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // Do not do it in the production.
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "hello-world-kp" {
    key_name = "hello-world-kp"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

resource "aws_instance" "hello-world-ec2" {

    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.hello-world-subnet-public-1.id}"
    vpc_security_group_ids = ["${aws_security_group.hello-world-sg.id}"]
    key_name = "${aws_key_pair.hello-world-kp.id}"

    provisioner "file" {
        source = "install_docker.sh"
        destination = "/tmp/install_docker.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/install_docker.sh",
            "sudo /tmp/install_docker.sh"
        ]
    }

    connection {
        type = "ssh"
        host = self.public_ip
        user = "${var.EC2_USER}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }
}
