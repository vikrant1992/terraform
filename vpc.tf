provider "aws" {
  access_key = "AKIAION65XYYF3YTUGIQ"
  secret_key = "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"
  region = "us-west-2"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags {
      Name = "myvpc"
}

}
resource "aws_subnet" "subnet1" {
  vpc_id      = "${aws_vpc.myvpc.id}"
  cidr_block   = "10.0.1.0/24"
  tags {
      Name = "public"
  }


}
resource "aws_subnet" "subnet2" {
  vpc_id      = "${aws_vpc.myvpc.id}"
  cidr_block   = "10.0.2.0/24"
  tags {
      Name = "private"
  }
}

resource "aws_key_pair" "my_key" {
  key_name    = "vikk"
  public_key  = "${file("vikk.pub")}"
}

resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }


  vpc_id="${aws_vpc.myvpc.id}"

  tags {
    Name = "Web Server SG"
  }
}

resource "aws_security_group" "sgapp" {
  name = "vpc_test_app"
  description = " app- SG-- Allow incoming HTTP connections & SSH access from public instance"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["10.0.1.0/24"]
  }
  
egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.myvpc.id}"

  tags {
    Name = "Web Server SG"
  }
}


resource "aws_internet_gateway" "IGW" {
  vpc_id      = "${aws_vpc.myvpc.id}"
}


resource "aws_route_table" "custom_RT" {
    vpc_id      = "${aws_vpc.myvpc.id}"
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.IGW.id}"
    }
    tags {
        Name = "Custom_RT"
    }
}
resource "aws_route_table_association" "public_RT" {
    subnet_id = "${aws_subnet.subnet1.id}"
    route_table_id = "${aws_route_table.custom_RT.id}"
}

resource "aws_eip" "lb" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.lb.id}"
  subnet_id     = "${aws_subnet.public.id}"
}


resource "aws_route_table" "main" {
    vpc_id      = "${aws_vpc.myvpc.id}"
    route{
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.gw.id}"
    }
    tags {
        Name = "main RT"
    }
}
resource "aws_route_table_association" "public_RT" {
    subnet_id = "${aws_subnet.subnet2.id}"
    route_table_id = "${aws_route_table.main.id}"
}


#Instance public 
resource "aws_instance" "web" {
  ami           = "ami-01bbe152bf19d0289"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = "${aws_key_pair.my_key.key_name}"

  subnet_id     = "${aws_subnet.subnet1.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
  
  user_data	= "${file("bashscript.sh")}"

  tags {
      Name = "web"
  }

}

#Instance 2
resource "aws_instance" "app" {
  ami           = "ami-01bbe152bf19d0289"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = "${aws_key_pair.my_key.key_name}"

  subnet_id     = "${aws_subnet.subnet2.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.sgapp.id}"]
  tags {
      Name = "app"
  }

}








