#!/bin/bash
# Input Variables
CLUSTER_NAME="PLACEHOLDER_CLUSTER_NAME"
REGION="PLACEHOLDER_REGION"
SERVICE_ACCOUNT_NAME="${CLUSTER_NAME}-aws-load-balancer-controller"
NAMESPACE="kube-system"
UNIQUE_ROLE_NAME="${CLUSTER_NAME}-AmazonEKSLoadBalancerControllerRole"

# Check if a region argument is provided
if [ -n "$1" ]; then
  REGION=$1
fi

# IAM Policy for Service Account
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

policy_name="${CLUSTER_NAME}-AWSLoadBalancerControllerIAMPolicy"
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='${policy_name}'].Arn" --output text)

# If $POLICY_ARN is empty string, create new policy
if [ -z "$POLICY_ARN" ]; then
    echo "Creating new policy: ${policy_name}"
    POLICY_ARN=$(aws iam create-policy \
        --policy-name "${policy_name}" \
        --policy-document file://iam_policy.json \
        --output json | jq -r '.Policy.Arn')
else
    echo "Using existing policy: ${policy_name}"
fi

echo "Policy ARN: ${POLICY_ARN}"

# Get all node names in the cluster
NODE_NAMES=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name")

# Loop through each node and fetch the instance ID
echo "Fetching instance IDs for all nodes in the cluster..."
for NODE_NAME in $NODE_NAMES
do
  # Get the ProviderID from the node description (which includes the instance ID)
  INSTANCE_ID=$(kubectl describe node $NODE_NAME | grep "ProviderID" | awk -F'/' '{print $NF}')

  # Modify instance metadata options
  aws ec2 modify-instance-metadata-options \
    --instance-id $INSTANCE_ID \
    --region $REGION \
    --http-tokens optional \
    --http-endpoint enabled \
    --http-protocol-ipv6 disabled \
    --instance-metadata-tags disabled

  # Describe instance metadata options
  METADATA_OPTIONS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].MetadataOptions" --region $REGION --output json)

  # Print the node name, instance ID, and metadata options
  echo "Node: $NODE_NAME, Instance ID: $INSTANCE_ID"
  echo "Metadata Options: $METADATA_OPTIONS"
done

sleep 20

# Associate IAM OIDC provider with the cluster
eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$CLUSTER_NAME --approve

# Get VPC ID from EKS cluster description
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)

if [ -z "$VPC_ID" ]; then
  echo "Failed to retrieve VPC ID for cluster $CLUSTER_NAME"
  exit 1
fi

# Add the EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Create IAM role and service account for the AWS Load Balancer Controller
eksctl create iamserviceaccount \
  --region $REGION \
  --name $SERVICE_ACCOUNT_NAME \
  --namespace $NAMESPACE \
  --cluster $CLUSTER_NAME \
  --role-name $UNIQUE_ROLE_NAME \
  --attach-policy-arn ${POLICY_ARN} \
  --approve \
  --override-existing-serviceaccounts

# Install the AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n $NAMESPACE \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set region=$REGION \
  --set vpcId=$VPC_ID
  
echo "AWS Load Balancer Controller installed successfully!"
