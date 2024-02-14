
variable "vpc_region" {
    description = "passed on region from parent"
    type = string
}
           ####      VPC configuration         ########
variable "vpc_cidr" {
    description = "put your value of whole block for cidr on the vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_tenacity" {
    type = string
    default = "default"
}
variable "dns_support" {
    type = string
    default = "true"
}
variable "dns_hostnames" {
    type = string
    default = "true"
}
variable "vpc_tag" {
    type = map(string)
    default = {
      Name = "main-Ariel-VPC-assignment"
      ManagedBy = "terraform"
    }
  
}
 