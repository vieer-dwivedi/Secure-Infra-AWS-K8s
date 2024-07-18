#!/bin/bash

set -e

RESOURCE_PREFIX=$1
ENVIRONMENT=$2

# Function to empty S3 bucket
empty_s3_bucket() {
  BUCKET_NAME="${RESOURCE_PREFIX}-s3-${ENVIRONMENT}"
  echo "Emptying S3 Bucket: $BUCKET_NAME"
  aws s3api delete-objects --bucket $BUCKET_NAME --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
  aws s3 rm s3://$BUCKET_NAME --recursive
}

# Function to empty ECR repository
empty_ecr_repository() {
  REPO_NAME="${RESOURCE_PREFIX}-ecr-${ENVIRONMENT}"
  echo "Emptying ECR Repository: $REPO_NAME"
  IMAGE_TAGS=$(aws ecr list-images --repository-name $REPO_NAME --query 'imageIds[*]' --output json)
  if [ "$IMAGE_TAGS" != "[]" ]; then
    aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids "$IMAGE_TAGS"
  else
    echo "No images to delete in repository $REPO_NAME"
  fi
}

# Function to delete Load Balancer
delete_load_balancer() {
  echo "Deleting Load Balancer with tag elbv2.k8s.aws/cluster:${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
  LB_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(Tags[?Key=='elbv2.k8s.aws/cluster' && Value=='${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}'].Value, '${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}')].LoadBalancerArn" --output text)
  if [ -n "$LB_ARN" ]; then
    aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
  else
    echo "No Load Balancer found with the tag elbv2.k8s.aws/cluster:${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
  fi
}

# Execute the functions
empty_s3_bucket
empty_ecr_repository
delete_load_balancer
