#!/bin/bash

# Fetch IP addresses from Terraform outputs
ANSIBLE_PUB=$(terraform output -raw ansible_ip_pub)
ansible_ip=$(terraform output -raw ansible_ip_prv)
master_ip=$(terraform output -raw master_ip_prv)
MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
node_ip1=$(terraform output -raw worker_ip_prv1)
node_ip2=$(terraform output -raw worker_ip_prv2)
file="hosts.yaml" #to reference inside the ansible 
cluster_dns="arieldevops.tech"

echo "UPDATE HOSTS"
# transfer hosts.yaml to ansible machine
ssh-keyscan -H $ANSIBLE_PUB >> ~/.ssh/known_hosts
scp ./hosts.yaml ubuntu@$ANSIBLE_PUB:~/kubespray/inventory/mycluster

# updating hosts.yaml file + updating k8s-cluster.yml to use flannel and persistentVolume EBS(true) 
# and update aws.yml for CSI driver to be used
ssh ubuntu@$ANSIBLE_PUB << EOF
cd kubespray/inventory/mycluster

cp hosts.yaml hosts.yaml.bak
echo "backup hosts.yaml"
echo "Update ansible_host, ip, and access_ip for each node"

sed -i "/node1:/,/node2:/ {/ansible_host:/ s/ansible_host:.*/ansible_host: $master_ip/; /ip:/ s/ip:.*/ip: $master_ip/; /access_ip:/ s/access_ip:.*/access_ip: $master_ip/}" $file
sed -i "/node2:/,/node3:/ {/ansible_host:/ s/ansible_host:.*/ansible_host: $node_ip1/; /ip:/ s/ip:.*/ip: $node_ip1/; /access_ip:/ s/access_ip:.*/access_ip: $node_ip1/}" $file
sed -i "/node3:/,/kube_control_plane:/ {/ansible_host:/ s/ansible_host:.*/ansible_host: $node_ip2/; /ip:/ s/ip:.*/ip: $node_ip2/; /access_ip:/ s/access_ip:.*/access_ip: $node_ip2/}" $file
echo "hosts.yaml has been updated."
cd group_vars/k8s_cluster/
echo "((updating k8s-cluster.yml for flannel and aws CSI driver for EBS persistent volumes))"
sed -i 's/cluster_name: cluster.local/cluster_name: $cluster_dns/' k8s-cluster.yml
sed -i 's/kube_network_plugin: calico/kube_network_plugin: flannel/' k8s-cluster.yml
sed -i 's/persistent_volumes_enabled: false/persistent_volumes_enabled: true/' k8s-cluster.yml
echo "done updating k8s-cluster.yml"
cp addons.yml addons.yml.bak 
echo "back up addons.yml"
sed -i 's/dashboard_enabled: false/dashboard_enabled: true/' addons.yml
sed -i 's/ingress_nginx_enabled: false/ingress_nginx_enabled: true/' addons.yml
sed -i 's/ingress_nginx_host_network: false/ingress_nginx_host_network: true/' addons.yml
sed -i 's/cert_manager_enabled: false/cert_manager_enabled: true/' addons.yml
echo "updated : addons.yml updated: ingress ngnix, dashboard, cert manager"
echo " ..... "
echo "updating aws.yml for EBS use"
cd ../all
sed -i 's/# aws_ebs_csi_enabled: true/ aws_ebs_csi_enabled: true/' aws.yml
sed -i 's/# aws_ebs_csi_enable_volume_scheduling: true/ aws_ebs_csi_enable_volume_scheduling: true/' aws.yml
sed -i 's/# aws_ebs_csi_enable_volume_snapshot: false/ aws_ebs_csi_enable_volume_snapshot: true/' aws.yml
echo "k8s_cluster updated"
cd ../

echo "backup all.yml for...backup, about to change it"
cp ~/kubespray/inventory/mycluster/group_vars/all/all.yml  ~/kubespray/inventory/mycluster/group_vars/all/all.yml.backup
echo " updating all.yml for external cloud provider recognition by the cluster, using aws CCM"
sed -i '/^# *cloud_provider:/s/^# *//' ~/kubespray/inventory/mycluster/group_vars/all/all.yml
sed -i '/^cloud_provider:/s/:.*/: external/' ~/kubespray/inventory/mycluster/group_vars/all/all.yml


echo "generating keys for cluster"
sudo ssh-keygen -y -f /home/ubuntu/.ssh/id_rsa | sudo tee /home/ubuntu/.ssh/id_rsa.pub
sudo ssh-copy-id -i /home/ubuntu/.ssh/id_rsa.pub ubuntu@$master_ip
sudo ssh-copy-id -i /home/ubuntu/.ssh/id_rsa.pub ubuntu@$node_ip1
sudo ssh-copy-id  -i /home/ubuntu/.ssh/id_rsa.pub ubuntu@$node_ip2

echo "transfered keys"
echo " updating groups"
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ubuntu

echo "** start cluster creation**"
echo "----------------------------"
echo "disabling ipv4 + swapoff "
pwd
cd /home/ubuntu/kubespray
ansible all -i inventory/mycluster/hosts.yaml -m shell -a "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf" --private-key ~/.ssh/id_rsa
ansible all -i inventory/mycluster/hosts.yaml -m shell -a "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && sudo swapoff -a" --private-key ~/.ssh/id_rsa
echo "----------"
echo " begin cluster creation! "
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml --private-key ~/.ssh/id_rsa
echo "FINISHED creating cluster!"
echo " applying KUBECONFIG"
ssh -i /home/ubuntu/id_rsa ubuntu@$MASTER_K8S_IP_PUB
echo "logged to master node"
echo "updating KUBECONFIG now"
kubeconfig_path=$(sudo find / -name kubeconfig.conf | head -n 1|tail -n 1)
echo "export KUBECONFIG=${kubeconfig_path}" >> ~/.bashrc
echo " done updating"
echo "updating tokens and ca.crt"
token_path=$(sudo find /var/lib/kubelet  -name token | head -n 1)
crt_path=$(sudo find /etc/kubernetes -name ca.crt |head -n 1)
sudo sed -i "s|certificate-authority:.*|certificate-authority: $crt_path|" "$kubeconfig_path"
sudo sed -i "s|tokenFile:.*|tokenFile: $token_path|" "$kubeconfig_path"
cat $kubeconfig_path
exit
EOF
