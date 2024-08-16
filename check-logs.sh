#!/bin/bash

# Retrieve available S3 buckets
echo "Retrieving available S3 buckets..."
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Retrieve available RDS instance identifiers
echo "Retrieving available RDS instance identifiers..."
instances=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

# Retrieve available ELB load balancer names
echo "Retrieving available ELB load balancer names..."
load_balancers=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text)

# Check CloudTrail
echo -e "\nChecking CloudTrail..."
aws cloudtrail describe-trails

# List log groups in CloudWatch Logs
echo -e "\nChecking CloudWatch Logs..."
aws logs describe-log-groups

# List VPC flow log configurations
echo -e "\nChecking VPC Flow Logs..."
aws ec2 describe-flow-logs

# Check S3 Server Access Logs for each bucket
echo -e "\nChecking S3 Server Access Logs..."
for bucket in $buckets; do
  echo "Bucket: $bucket"
  aws s3api get-bucket-logging --bucket "$bucket"
done

# Check RDS Logs for each instance
echo -e "\nChecking RDS Logs..."
for instance in $instances; do
  echo "RDS Instance: $instance"
  aws rds describe-db-log-files --db-instance-identifier "$instance"
done

# Check ELB Access Logs for each load balancer
echo -e "\nChecking ELB Access Logs..."
for lb in $load_balancers; do
  echo "Load Balancer: $lb"
  aws elb describe-load-balancers --load-balancer-names "$lb"
done