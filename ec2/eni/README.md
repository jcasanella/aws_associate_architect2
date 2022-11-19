# Assign an ENI to an EC2 instance

The purpose of this exercise is to verify that an ENI can be assigned to another EC2 instance only if they're part of the same AZ otherwise is not possible.
Create differents EC2 instances in different subnets, assign the ENI to one of the EC2 instances. Once they have been created try to change the ENI from 
an EC2 instance to another one available in a different AZ

## Terraform features

Create a loop using count and iterate subnets using the counter index.