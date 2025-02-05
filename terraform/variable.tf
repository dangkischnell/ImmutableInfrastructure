# variable "access_key" { }
# variable "secret_key" { }
# variable "region" {
#   default = "us-east-2"
# }
variable "availability_zone" {
  default = "eu-central-1a"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "dev"
}