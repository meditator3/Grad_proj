MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
scp cluster-autoscaler-autodiscover.yaml ubuntu@$MASTER_K8S_IP_PUB:~
ssh  ubuntu@$MASTER_K8S_IP_PUB <<EOF
echo " installing AWS Cloud Controller Manager"
sudo helm repo add aws-cloud-controller-manager https://kubernetes.github.io/cloud-provider-aws
sudo helm repo update
sudo cp cloud-values.yaml /root/cloud-values.yaml
sudo cp cluster-autoscaler-autodiscover.yaml /root/cluster-autoscaler-autodiscover.yaml
sudo helm upgrade --install aws-cloud-controller-manager aws-cloud-controller-manager/aws-cloud-controller-manager -n kube-system -f cloud-values.yaml
echo " installing cluster autoscaler using autodiscover configuration"
sudo kubectl apply -f cluster-autoscaler-autodiscover.yaml
EOF
