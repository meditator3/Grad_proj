MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
ssh  ubuntu@$MASTER_K8S_IP_PUB <<EOF
echo " installing AWS Cloud Controller Manager"
sudo helm repo add aws-cloud-controller-manager https://kubernetes.github.io/cloud-provider-aws
sudo helm repo update
sudo helm upgrade --install aws-cloud-controller-manager aws-cloud-controller-manager/aws-cloud-controller-manager -n kube-system -f cloud-values.yaml
echo " installing cluster autoscaler using autodiscover configuration"
sudo kubectl apply -f cluster-autoscaler-autodiscover.yaml
EOF
