


# module "vpc"  {
#     source = "./vpc_module"
#     vpc_region = var.AWS_REGION
    
# }
module "ansible" {
    source = "./ansible_module"
    region = var.AWS_REGION  # passed to ansible module
    public_subnet1 = local.subnet_ids[0] 
}
