variable "aws_region" {
  description = "The AWS region to create things in."
  default = "us-west-2"
}

# ubuntu-trusty-14.04 (x64)
variable "aws_amis" {
  default = {
    "us-west-2" = "ami-09569069"
    "us-west-2" = "ami-9abea4fb"
     
  }
}


