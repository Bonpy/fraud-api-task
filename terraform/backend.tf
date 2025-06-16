terraform {
  backend "s3" {
    bucket       = "tf-state-bucket"
    key          = "fraud-api/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = false
    encrypt      = true
  }
}
