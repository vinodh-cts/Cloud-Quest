terraform {
  backend "s3" {
    bucket = "PLACEHOLDER_S3_BUCKET_NAME"
    key    = "PLACEHOLDER_CLUSTER_NAME-ecr/terraform.tfstate.json"
    region = "us-east-1"
  }
}
