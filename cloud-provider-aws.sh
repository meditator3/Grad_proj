MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
echo " copying autoscaler"
ssh-keyscan  -H $MASTER_K8S_IP_PUB >> ~/.ssh/known_hosts
scp  -i ~/.ssh/id_rsa cluster-autoscaler-autodiscover.yaml   ubuntu@$MASTER_K8S_IP_PUB:~
scp cloud-values.yaml ubuntu@$MASTER_K8S_IP_PUB:~  # for aws CCM 
echo "finished copying autoscaler"
echo "logging in"
ssh  -i ~/.ssh/id_rsa ubuntu@$MASTER_K8S_IP_PUB <<EOF
echo "logged in"
echo "install helm"

# download and configure helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

echo " installing AWS Cloud Controller Manager"
sudo helm repo add aws-cloud-controller-manager https://kubernetes.github.io/cloud-provider-aws
sudo helm repo update
sudo cp cloud-values.yaml /root/cloud-values.yaml
sudo cp cluster-autoscaler-autodiscover.yaml /root/cluster-autoscaler-autodiscover.yaml
sudo helm upgrade --install aws-cloud-controller-manager aws-cloud-controller-manager/aws-cloud-controller-manager -n kube-system -f cloud-values.yaml
echo " installing cluster autoscaler using autodiscover configuration"
sudo kubectl apply -f cluster-autoscaler-autodiscover.yaml
EOF
