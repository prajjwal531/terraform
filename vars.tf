variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "SECURITY_GROUP" {
   type = "list"
   default = ["allow-all"]
}
variable "NAT-SECURITY" {
  type = "list"
  default = ["nat-security_groups"]
}
variable "AVAILABILITY_ZONE" {
  type = "list"
  default = ["us-west-2a","us-west-2b"]
}
variable "AWS_REGION" {
  default = "us-west-2"
}
variable "AMIS" {
  type = "map"
}
variable "PATH_TO_PUBLIC_KEY" {
   default = "myawskey.pub"
}
variable "PATH_TO_PRIVATE_KEY" {
   default = "myawskey"
}
