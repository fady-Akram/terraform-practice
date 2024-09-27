resource "aws_subnet" "subnet-test" {
   vpc_id= var.vpc_id
   cidr_block=var.subnet_cidr_block  
   availability_zone=var.avail_zone   
   tags={
      Name="${var.env}-subnet"
   }
}

resource "aws_internet_gateway" "igw" {
   vpc_id= var.vpc_id
   tags={
      Name="${var.env}-igw"
   }

}

resource "aws_route_table" "route-table" {  
   vpc_id= var.vpc_id
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
