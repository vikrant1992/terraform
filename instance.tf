provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
#  region = {}
}


resource "aws_instance" "web" {
  ami           = "${lookup(var.images,var.region)}"
  instance_type = "t2.micro"
  tenancy       = "default"

  associate_public_ip_address = true
  user_data     = "${file("bashscript.sh")}"

  tags {
      Name = "web"
  }
}
