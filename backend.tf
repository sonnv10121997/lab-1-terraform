terraform {
  backend "s3" {
    bucket         = "sonnv10121997-lab-1"
    dynamodb_table = "sonnv10121997-lab-1"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
  }
}
