variable "region" {
    description = "Insert your AWS region Code"
    default = "eu-west-2"
}

# variable "vpc_id" {
#     description = "ID of your VPC"
#     type = string
# }
variable "AMIS" {
    description = "choose AMU in context of region"
    type = map(string)
    default = {
         us-east-1    = "ami-0c7217cdde317cfec"
         eu-west-1    = "ami-0905a3c97561e0b69"
         eu-central-1 = "ami-0faab6bdbac9486fb"
         eu-west-2    = "ami-0f244b28200b93640"
    }
}

variable "public_subnet1" { # to be used by remote controller ansible instance
    description = "id of public subnet to pass to module"
    type = string
}


variable "PATH_TO_PRIVATE_KEY" {
    description = "path to private key in your pc"
    default = "~/.ssh/id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
    description = "path to public key in your pc"
    default = "~/.ssh/id_rsa.pub"  #previous one on local was mykey.pub
}

variable "INSTANCE_USERNAME" {
    description = "username of the instance"
    default = "ubuntu"
}
variable "key" {
    description = "existing key-pair"
    default = "ariel-key"
}
variable "instance_count_worker" {
  default = 2
}
variable "instance_count_master" {
  default = 1
}
