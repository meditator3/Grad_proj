output "vpc_name" {
    value = data.aws_vpc.existing_vpc.tags["Name"]
}
output "subnets_ids" { # output all subnets
    value = data.aws_subnets.existing_vpc_subnets.ids
}
# output "server_address" {
#     value = "${aws_instance.server.0.public_dns}"
# }
output "aws_region" {
    value = var.region
}

output "ansible_ip_prv" {
    value = aws_instance.ansible-remote.private_ip
}
output "master_ip_prv" {
    value = aws_instance.master-k8s[0].private_ip
}

output "ansible_ip_public" {
    value = aws_instance.ansible-remote.public_ip
}
output "master_ip_public" {
    value = aws_instance.master-k8s[0].public_ip
}
# TF outputs doesn't read list/array only json, so broke it apart/less dynamic
output "ip_k8s_worker_prv1" { 
    value = aws_instance.worker-k8s[0].private_ip
}
output "ip_k8s_worker_prv2" { 
    value = aws_instance.worker-k8s[1].private_ip
}