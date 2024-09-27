

resource "aws_vpc" "vpc" {
   cidr_block=var.vpc_cidr_block  
   tags={

      Name="${var.env}-vpc"
   }
}


module subnet {
  source = "./modules/subnet"
  subnet_cidr_block= var.subnet_cidr_block
  avail_zone = var.avail_zone
  env= var.env
  vpc_id = aws_vpc.vpc.id
  

}

module web {
   source = "./modules/web"
 vpc_id = aws_vpc.vpc.id
 image_name = var.image_name
 instance_type = var.instance_type
 avail_zone  = var.avail_zone
 subnet_id = module.subnet.subnet-det.id
 my_ip = var.my_ip 
 env = var.env
 
   }



