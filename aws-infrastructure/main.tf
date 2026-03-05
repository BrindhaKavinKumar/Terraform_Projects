resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "RT"
  }
}

resource "aws_route_table_association" "ass1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "ass2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "mysg" {
  name   = "my_sg"
  vpc_id = aws_vpc.my_vpc.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group"
  }

}

resource "aws_s3_bucket" "mybucket" {
  bucket = "terraform-vpc-sg-cloudchamp"

}

# resource "aws_s3_bucket_ownership_controls" "mybucket" {
#   bucket = aws_s3_bucket.mybucket.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "mybucket" {
#   bucket = aws_s3_bucket.mybucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_acl" "acl" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.mybucket,
#     aws_s3_bucket_public_access_block.mybucket

#   ]

#   bucket = aws_s3_bucket.mybucket.id
#   acl    = "public-read"
# }

resource "aws_instance" "inst1" {
  ami           = "ami-01f79b1e4a5c64257"
  instance_type = "t3.micro"
  # key_name = "terraformtask"
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  user_data_base64       = base64encode(file("userdata.sh"))

  tags = {
    Name = "instance1"
  }
}

resource "aws_instance" "inst2" {
  ami           = "ami-01f79b1e4a5c64257"
  instance_type = "t3.micro"
  # key_name = "terraformtask"
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  user_data_base64       = base64encode(file("userdatalb.sh"))

  tags = {
    Name = "instance2"
  }
}

# Create alb

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "LoadBalancer"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.inst1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.inst2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancer" {
  value = aws_lb.myalb.dns_name
}

  