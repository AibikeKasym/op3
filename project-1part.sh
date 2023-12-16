#!/bin/bash
 
# Define variables 
vpc_cidr="10.0.0.0/16"
subnet1_cidr="10.0.1.0/24"
subnet2_cidr="10.0.2.0/24"
subnet3_cidr="10.0.3.0/24"
instance_name="project3"
 
# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block "$vpc_cidr" --query Vpc.VpcId --output text)
 
# Create 3 subnets in the us-east-2 region
subnet1_id=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$subnet1_cidr" --query Subnet.SubnetId --output text)
subnet2_id=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$subnet2_cidr" --query Subnet.SubnetId --output text)
subnet3_id=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$subnet3_cidr" --query Subnet.SubnetId --output text)
 
# Create the Internet Gateway
igw_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
 
# Attach the IGW to the VPC
aws ec2 attach-internet-gateway --vpc-id "$vpc_id" --internet-gateway-id "$igw_id"
 
# Create the Route Table
route_table=$(aws ec2 create-route-table --vpc-id "$vpc_id" --query RouteTable.RouteTableId --output text)
 
# Add the RT to the IGW
aws ec2 create-route --route-table-id "$route_table" --destination-cidr-block 0.0.0.0/0 --gateway-id "$igw_id"
 
# Associate the RT with subnets 1, 2, 3
aws ec2 associate-route-table --subnet-id "$subnet1_id" --route-table-id "$route_table"
aws ec2 associate-route-table --subnet-id "$subnet2_id" --route-table-id "$route_table"
aws ec2 associate-route-table --subnet-id "$subnet3_id" --route-table-id "$route_table"
 
# Create a security group
sg_id=$(aws ec2 create-security-group --group-name EC2SecurityGroup --description "Demo Security Group" --vpc-id "$vpc_id" --query GroupId --output text)
 
# Open the Port 22 for SSH connectivity
aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 22 --cidr 0.0.0.0/0
 
# Create a Key pair
aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem
# Change the permissions to read-only (400)
chmod 400 EC2KeyPair.pem
 
# Deploy the instance
aws ec2 run-instances --image-id ami-048e636f368eb3006 --count 1 --instance-type t2.micro --security-group-ids "$sg_id" --subnet-id "$subnet1_id" --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\"$instance_name\"}]"
# Get the public ID of the Instance
ec2_public_ip=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --filters Name=tag:Name,Values="$instance_name" --output text)

# SSH to the Project3 Instance
ssh -i "EC2KeyPair.pem" ec2-user@"$ec2_public_ip" 
