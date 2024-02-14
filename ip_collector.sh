#!/bin/bash
                # this is a script wrapper after running terraform apply to do the following: #

# Fetch instance IPs from Terraform outputs
ANSIBLE_REMOTE_IP_PRV=$(terraform output -raw ansible_ip_prv)
MASTER_K8S_IP_PRV=$(terraform output -raw  master_ip_prv)
ANSIBLE_REMOTE_IP_PUB=$(terraform output -raw  ansible_ip_pub)
MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
WORKER_K8S_IP_PRV1=$(terraform output -raw  worker_ip_prv1)
WORKER_K8S_IP_PRV2=$(terraform output -raw  worker_ip_prv2)

# Use SSH to configure /etc/ansible/hosts on the ansible-remote instance
# scp key to known hosts to remove prompts of known ip
# configuring and injecting ip outputs to the hosts ansible file
# checking ansible components pings

ssh-keyscan -H $ANSIBLE_REMOTE_IP_PUB >> ~/.ssh/known_hosts
scp ~/.ssh/id_rsa ubuntu@$ANSIBLE_REMOTE_IP_PUB:~/.ssh/id_rsa
ssh ubuntu@$ANSIBLE_REMOTE_IP_PUB << EOF



echo " starting injection of IPs to hosts ansible"
echo "[remote-controller]" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "ansible ansible_host=$ANSIBLE_REMOTE_IP_PRV ansible_connection=local ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa ansible_become=true" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "[k8s_master]" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "master ansible_host=$MASTER_K8S_IP_PRV ansible_connection=ssh ansible_user=ubuntu  ansible_become=true" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "[k8s_worker]" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "worker ansible_host=$WORKER_K8S_IP_PRV1 ansible_connection=ssh ansible_user=ubuntu  ansible_become=true" | sudo tee -a /etc/ansible/hosts > /dev/null
echo "worker ansible_host=$WORKER_K8S_IP_PRV2 ansible_connection=ssh ansible_user=ubuntu  ansible_become=true" | sudo tee -a /etc/ansible/hosts > /dev/null


echo -e "[defaults]\ninventory=./hosts" | sudo tee -a /etc/ansible/ansible.cfg

echo "copied something"
echo "[all:vars] " | sudo tee -a /etc/ansible/hosts 
echo "ansible_python_interpreter=/usr/bin/python3" | sudo tee -a /etc/ansible/hosts 
cat /etc/ansible/hosts
ansible-inventory --list -y
whoami
echo "ansible all -m ping --private-key ~/.ssh/id_rsa"
exit
EOF
