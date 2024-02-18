MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
echo " copying autoscaler"
scp  -i ~/.ssh.id_rsa cluster-autoscaler-autodiscover.yaml   ubuntu@$MASTER_K8S_IP_PUB:~
echo "finished copying autoscaler"
echo "logging in"
ssh  -i ~/.ssh.id_rsa ubuntu@$MASTER_K8S_IP_PUB <<EOF
echo "logged in"
echo " installing AWS Cloud Controller Manager"
sudo helm repo add aws-cloud-controller-manager https://kubernetes.github.io/cloud-provider-aws
sudo helm repo update
sudo cp cloud-values.yaml /root/cloud-values.yaml
sudo cp cluster-autoscaler-autodiscover.yaml /root/cluster-autoscaler-autodiscover.yaml
sudo helm upgrade --install aws-cloud-controller-manager aws-cloud-controller-manager/aws-cloud-controller-manager -n kube-system -f cloud-values.yaml
echo " installing cluster autoscaler using autodiscover configuration"
sudo kubectl apply -f cluster-autoscaler-autodiscover.yaml
EOF
