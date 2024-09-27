resource "aws_security_group" "sec-grp" {
name = "${var.env}-sec-grp"
vpc_id = var.vpc_id
   ingress {
   from_port   = 22
   to_port     = 22
   cidr_blocks = [var.my_ip]
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
      values=[var.image_name]
   }
   filter {
      name="virtualization-type"
      values=["hvm"]
   }

}


resource "aws_instance" "ec2" {
   ami=data.aws_ami.amazon-machine-image.id
   instance_type=var.instance_type   
   subnet_id=var.subnet_id
   vpc_security_group_ids=[aws_security_group.sec-grp.id]
   availability_zone=var.avail_zone  
   associate_public_ip_address= true
   key_name=aws_key_pair.ssh-key.key_name        
   user_data= file("userdata.sh")
   tags={
      Name="${var.env}-terraform-ec2"   
   }

}

resource "aws_key_pair" "ssh-key" {
   key_name="jen.pem"
   public_key=file("~/.ssh/id_rsa.pub")
}
