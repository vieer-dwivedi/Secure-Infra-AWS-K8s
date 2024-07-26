#!/bin/bash
set -e

RESOURCE_PREFIX=$1
ENVIRONMENT=$2

delete_s3_objects() {
    local bucket=$1
    local query_key=$2
    local description=$3

    echo "Checking if ${description}[] is present"
    aws s3api list-object-versions --bucket "$bucket" --query "$query_key" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "${description}[] found, executing delete-objects for ${description}"
        aws s3api list-object-versions --bucket "$bucket" --query "${description}[].{Key:Key,VersionId:VersionId}" --output text | \
        while read -r key version_id; do
            if [ -n "$key" ] && [ -n "$version_id" ]; then
                echo "Deleting object with Key=$key and VersionId=$version_id"
                aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version_id"
            fi
        done
    fi
}

# Empty S3 Bucket
S3_BUCKET="${RESOURCE_PREFIX}-s3-${ENVIRONMENT}"
echo "Emptying S3 Bucket: $S3_BUCKET"
delete_s3_objects "$S3_BUCKET" "DeleteMarkers" "DeleteMarkers"
delete_s3_objects "$S3_BUCKET" "Versions" "Versions"

# Empty ECR Repository
ECR_REPOSITORY="${RESOURCE_PREFIX}-ecr-${ENVIRONMENT}"
echo "Emptying ECR Repository: $ECR_REPOSITORY"
if aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" > /dev/null 2>&1; then
    aws ecr list-images --repository-name "$ECR_REPOSITORY" --output json | jq -r '.imageIds[] | select(.imageDigest and .imageTag) | .imageDigest + " " + .imageTag' | \
    while read -r image_digest image_tag; do
        echo "Deleting image with Digest=$image_digest and Tag=$image_tag"
        aws ecr batch-delete-image --repository-name "$ECR_REPOSITORY" --image-ids imageDigest="$image_digest" imageTag="$image_tag"
    done
else
    echo "ECR Repository $ECR_REPOSITORY not found"
fi

# Delete Load Balancers
TAG_KEY="elbv2.k8s.aws/cluster"
TAG_VALUE="${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
echo "Deleting Load Balancer with tag ${TAG_KEY}:${TAG_VALUE}"

# Fetch the load balancer ARN
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text | while read -r arn; do aws elbv2 describe-tags --resource-arns "$arn" --query "TagDescriptions[?Tags[?Key=='${TAG_KEY}'&&Value=='${TAG_VALUE}']].ResourceArn" --output text; done)

if [ -z "$LOAD_BALANCER_ARN" ]; then
    echo "No Load Balancer found with the specified tag: ${TAG_KEY}:${TAG_VALUE}"
else
    echo "Deleting Load Balancer with ARN: $LOAD_BALANCER_ARN"
    
    # Delete all listeners associated with the load balancer
    LISTENERS=$(aws elbv2 describe-listeners --load-balancer-arn "$LOAD_BALANCER_ARN" --query "Listeners[].ListenerArn" --output text)
    for LISTENER in $LISTENERS; do
        echo "Deleting Listener: $LISTENER"
        aws elbv2 delete-listener --listener-arn "$LISTENER"
    done
    
    # Wait for a short period to ensure changes are processed
    echo "Waiting for 30 seconds to ensure changes are processed..."
    sleep 30
    
    # Describe the load balancer to get the associated target groups
    TARGET_GROUP_ARNS=$(aws elbv2 describe-target-groups --load-balancer-arn "$LOAD_BALANCER_ARN" --query "TargetGroups[].TargetGroupArn" --output text)
    
    if [ -z "$TARGET_GROUP_ARNS" ]; then
        echo "No Target Groups found for the Load Balancer with ARN: $LOAD_BALANCER_ARN"
    else
        for TARGET_GROUP_ARN in $TARGET_GROUP_ARNS; do
            echo "Attempting to delete Target Group with ARN: $TARGET_GROUP_ARN"
            if aws elbv2 delete-target-group --target-group-arn "$TARGET_GROUP_ARN"; then
                echo "Successfully deleted Target Group: $TARGET_GROUP_ARN"
            else
                echo "Failed to delete Target Group: $TARGET_GROUP_ARN. It may still be in use."
            fi
        done
    fi
    
    # Delete the load balancer
    if aws elbv2 delete-load-balancer --load-balancer-arn "$LOAD_BALANCER_ARN"; then
        echo "Successfully deleted Load Balancer: $LOAD_BALANCER_ARN"
    else
        echo "Failed to delete Load Balancer: $LOAD_BALANCER_ARN"
    fi
fi