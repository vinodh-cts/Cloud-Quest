terraform {
  backend "s3" {
    bucket = "PlACEHOLDER_S3_BUCKET_NAME"
    key    = "PLACEHOLDER_CLUSTER_NAME-eks/terraform.tfstate.json"
    region = "us-east-1"
  }
}
