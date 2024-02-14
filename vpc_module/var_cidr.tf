   # public group to link to IGW
variable "cidr_main_public" {
    description = "put your value for main public CIDR block"
    type = string
    default = "0.0.0.0/0"
}
#private group to link to NAT
variable "cidr_main_private" {
    description = "put your value for main private CIDR block"
    type = string
    default = "0.0.0.0/0"
}
#public cidr/AZ

variable "cidr_public_az1" {
    description = "put your value for public az CIDR block"
    default = "10.0.101.0/24"
}
variable "cidr_public_az2" {
    description = "put your value for public az CIDR block"
    default = "10.0.102.0/24"
}
variable "cidr_public_az3" {
    description = "put your value for public az CIDR block"
    default = "10.0.103.0/24"
}

#private cidr/AZ
variable "cidr_private_az1" {
    description = "put your value for public az CIDR block"
    default = "10.0.1.0/24"
}
variable "cidr_private_az2" {
    description = "put your value for public az CIDR block"
    default = "10.0.2.0/24"
}
variable "cidr_private_az3" {
    description = "put your value for public az CIDR block"
    default = "10.0.3.0/24"
}