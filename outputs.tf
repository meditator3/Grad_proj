output "vpc_name" {
    value = module.ansible.vpc_name
}
output "subnets_ids" { # output all subnets
    value = module.ansible.subnets_ids
}
# output "server_address" {
#     value = "${aws_instance.server.0.public_dns}"
# }
output "aws_region" {
    value = module.ansible.aws_region 
}
locals {
  subnet_ids = module.ansible.subnets_ids # pull ids of subnet modulesname 
  subnet_public1 = module.ansible.subnets_ids[0]

}

data "aws_subnet" "module_subnet_names" {
  count = length(local.subnet_ids) #count subnets
  id    = local.subnet_ids[count.index] # save them as list
}

output "subnet_names" { #display list to pass the names of all subnets 
  value = { for subnet in data.aws_subnet.module_subnet_names : subnet.id => subnet.tags["Name"] }
} 

output "public1_subnet" {
    value = local.subnet_public1
}

                # outputs of ansible hosts ip ##
output "ansible_ip_prv" {
    value = module.ansible.ansible_ip_prv
}
output "master_ip_prv" {
    value = module.ansible.master_ip_prv
}
output "ansible_ip_pub" {
    value = module.ansible.ansible_ip_public
}
output "master_ip_pub" {
    value = module.ansible.master_ip_public
}
output "worker_ip_prv1" {
    value = module.ansible.ip_k8s_worker_prv1
}
output "worker_ip_prv2" {
    value = module.ansible.ip_k8s_worker_prv2
}
