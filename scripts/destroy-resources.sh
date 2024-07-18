#!/bin/bash

RESOURCE_PREFIX=$1
ENVIRONMENT=$2

# Function to check if a value is null or empty
function is_null_or_empty() {
  [ -z "$1" ] || [ "$1" == "null" ]
}

# Empty S3 Buckets
S3_BUCKET="${RESOURCE_PREFIX}-s3-${ENVIRONMENT}"
echo "Emptying S3 Bucket: $S3_BUCKET"
aws s3api list-object-versions --bucket "$S3_BUCKET" --output json | jq -r '.Versions[] | select(.VersionId) | .Key + " " + .VersionId' | \
while read -r key version_id; do
  if is_null_or_empty "$key" || is_null_or_empty "$version_id"; then
    echo "Skipping invalid key/version_id: $key $version_id"
  else
    aws s3api delete-object --bucket "$S3_BUCKET" --key "$key" --version-id "$version_id"
  fi
done

# Empty ECR Repositories
ECR_REPOSITORY="${RESOURCE_PREFIX}-ecr-${ENVIRONMENT}"
echo "Emptying ECR Repository: $ECR_REPOSITORY"
aws ecr list-images --repository-name "$ECR_REPOSITORY" --output json | jq -r '.imageIds[] | select(.imageDigest and .imageTag) | .imageDigest + " " + .imageTag' | \
while read -r image_digest image_tag; do
  if is_null_or_empty "$image_digest" || is_null_or_empty "$image_tag"; then
    echo "Skipping invalid image_digest/image_tag: $image_digest $image_tag"
  else
    aws ecr batch-delete-image --repository-name "$ECR_REPOSITORY" --image-ids imageDigest="$image_digest" imageTag="$image_tag"
  fi
done

# Delete Load Balancers
TAG_VALUE="${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
echo "Deleting Load Balancer with tag elbv2.k8s.aws/cluster:$TAG_VALUE"
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(Tags[?Key=='elbv2.k8s.aws/cluster'].Value, '$TAG_VALUE')].LoadBalancerArn" --output text)

if is_null_or_empty "$LOAD_BALANCER_ARN"; then
  echo "No Load Balancer found with the specified tag: elbv2.k8s.aws/cluster:$TAG_VALUE"
else
  aws elbv2 delete-load-balancer --load-balancer-arn "$LOAD_BALANCER_ARN"
fi