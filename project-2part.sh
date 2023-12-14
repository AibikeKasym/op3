#!/bin/bash
#Create json file 
touch project.json

# Modify project.json file
cat <<EOF > project.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"Service": "ec2.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
#Create IAM role
aws iam create-role --role-name kaizen --assume-role-policy-document file://project.json

#Attach policy 
aws iam attach-role-policy --role-name kaizen --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess 
#Create an instance profile 
aws iam create-instance-profile --instance-profile-name project3

#Add role to instance profile
aws iam add-role-to-instance-profile --instance-profile-name project3 --role-name kaizen
#Cp file from one bucket to another 
aws s3 cp s3://octgroup-project3/ourfile.png s3://octgroup-project3.1
