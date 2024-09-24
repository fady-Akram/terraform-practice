
variable "vpc_cidr_block" {
   description="vpc cidr block"    

}

variable "subnet_cidr_block"{}
variable "env" {}
variable "avail_zone" {}
variable "my-ip" {}
variable "instance_type" {}

resource "aws_vpc" "vpc" {
   cidr_block=var.vpc_cidr_block  
   tags={

      Name="${var.env}-vpc"
   }
}

resource "aws_subnet" "subnet-test" {
   vpc_id= aws_vpc.vpc.id
   cidr_block=var.subnet_cidr_block  
   availability_zone=var.avail_zone   
   tags={
      Name="${var.env}-subnet"
   }
}

resource "aws_internet_gateway" "igw" {
   vpc_id= aws_vpc.vpc.id
   tags={
      Name="${var.env}-igw"
   }

}

resource "aws_route_table" "route-table" {  
   vpc_id= aws_vpc.vpc.id
   route{
      cidr_block="0.0.0.0/0" 
      gateway_id=aws_internet_gateway.igw.id
   }
   tags={
      Name="${var.env}-rt"

   }

}


resource "aws_route_table_association" "subnet-rt" {  
   subnet_id=aws_subnet.subnet-test.id
   route_table_id=aws_route_table.route-table.id
}


resource "aws_security_group" "sec-grp" {
name = "${var.env}-sec-grp"
vpc_id = aws_vpc.vpc.id
   ingress {
   from_port   = 22
   to_port     = 22
   cidr_blocks = [var.my-ip]
   protocol    = "tcp"
}
   ingress {
   from_port   = 8080
   to_port     = 8080
   cidr_blocks = ["0.0.0.0/0"]
   protocol    = "tcp"
}
   ingress {
   from_port   = 80
   to_port     = 80
   cidr_blocks = ["0.0.0.0/0"]
   protocol    = "tcp"
}
   tags = {
      Name = "${var.env}-sec-grp"
}
   egress{
      from_port=0
      to_port=0
      cidr_blocks=["0.0.0.0/0"] 
      protocol= "-1"
      prefix_list_ids=[]   
   }
}


data "aws_ami" "amazon-machine-image"{
   most_recent= true 
   owners=["amazon"]
   filter {
      name="name"
      values=["amzn2-ami-*-x86_64-gp2"]
   }
   filter {
      name="virtualization-type"
      values=["hvm"]
   }

}
output "aws_ami_id" {
   value=data.aws_ami.amazon-machine-image.id
}


resource "aws_instance" "ec2" {
   ami=data.aws_ami.amazon-machine-image.id
   instance_type=var.instance_type   
   subnet_id=aws_subnet.subnet-test.id
   vpc_security_group_ids=[aws_security_group.sec-grp.id]
   availability_zone=var.avail_zone  
   associate_public_ip_address= true
   key_name=aws_key_pair.ssh-key.key_name        
   user_data = file("userdata.sh")
   tags={
      Name="${var.env}-terraform-ec2"   
   }

}

resource "aws_key_pair" "ssh-key" {
   key_name="jen.pem"
   public_key=file("~/.ssh/id_rsa.pub")
}

output "ec2-public-ip" {
   value=aws_instance.ec2.public_ip
}