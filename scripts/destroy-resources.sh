#!/bin/bash

RESOURCE_PREFIX=$1
ENVIRONMENT=$2

# Function to delete S3 objects based on provided query
delete_s3_objects() {
  local bucket=$1
  local query=$2
  local description=$3

  echo "Checking if $description[] is present"
  if aws s3api list-object-versions --bucket "$bucket" --query "$query" > /dev/null 2>&1; then
    echo "$description[] found, executing delete-objects for $description"
    aws s3api list-object-versions --bucket "$bucket" --query "$query[].{Key:Key,VersionId:VersionId}" --output text | \
    while read -r key version_id; do
      echo "Deleting object with Key=$key and VersionId=$version_id"
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version_id"
    done
  else
    echo "$description[] not found"
  fi
}

# Empty S3 Buckets
S3_BUCKET="${RESOURCE_PREFIX}-s3-${ENVIRONMENT}"
echo "Emptying S3 Bucket: $S3_BUCKET"
delete_s3_objects "$S3_BUCKET" "DeleteMarkers" "DeleteMarkers"
delete_s3_objects "$S3_BUCKET" "Versions" "Versions"

# Empty ECR Repositories
ECR_REPOSITORY="${RESOURCE_PREFIX}-ecr-${ENVIRONMENT}"
echo "Emptying ECR Repository: $ECR_REPOSITORY"
aws ecr list-images --repository-name "$ECR_REPOSITORY" --output json | jq -r '.imageIds[] | select(.imageDigest and .imageTag) | .imageDigest + " " + .imageTag' | \
while read -r image_digest image_tag; do
  echo "Deleting image with Digest=$image_digest and Tag=$image_tag"
  aws ecr batch-delete-image --repository-name "$ECR_REPOSITORY" --image-ids imageDigest="$image_digest" imageTag="$image_tag"
done

# Delete Load Balancers
TAG_KEY="elbv2.k8s.aws/cluster"
TAG_VALUE="${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
echo "Deleting Load Balancer with tag ${TAG_KEY}:${TAG_VALUE}"
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(Tags[?Key=='${TAG_KEY}'].Value, '${TAG_VALUE}')].LoadBalancerArn" --output text)

if [ -z "$LOAD_BALANCER_ARN" ]; then
  echo "No Load Balancer found with the specified tag: ${TAG_KEY}:${TAG_VALUE}"
else
  echo "Deleting Load Balancer with ARN: $LOAD_BALANCER_ARN"
  aws elbv2 delete-load-balancer --load-balancer-arn "$LOAD_BALANCER_ARN"
fi