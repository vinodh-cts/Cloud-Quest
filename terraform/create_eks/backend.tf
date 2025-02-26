terraform {
  backend "s3" {
    bucket = "sdp-dev-statefiles"
    key    = "new-test-eks/terraform.tfstate.json"
    region = "us-east-1"
  }
}
