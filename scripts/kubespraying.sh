#!/bin/bash

ANSIBLE_REMOTE_IP_PRV=$(terraform output -raw ansible_ip_prv)
MASTER_K8S_IP_PRV=$(terraform output -raw master_ip_prv)
ANSIBLE_REMOTE_IP_PUB=$(terraform output -raw ansible_ip_pub)
WORKER_K8S_IP_PRV1=$(terraform output -raw worker_ip_prv1)
WORKER_K8S_IP_PRV2=$(terraform output -raw worker_ip_prv2)

# pulling kubespray & updating python
ssh  ubuntu@$ANSIBLE_REMOTE_IP_PUB << EOF
sudo apt update
sudo apt install git python3 python3-pip -y
git clone https://github.com/kubernetes-incubator/kubespray.git
cd kubespray
sudo pip install -r requirements.txt
ansible --version

# creating ip for cluster
echo " ## creating ip for cluster ##"
echo "-------------------------------"
sudo cp -rfp inventory/sample inventory/mycluster
declare -a IPS=($MASTER_K8S_IP_PRV, $WORKER_K8S_IP_PRV1, $WORKER_K8S_IP_PRV2)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

EOF