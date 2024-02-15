ssh  ubuntu@$MASTER_K8S_IP_PUB <<EOF
echo " installing AWS Cloud Controller Manager"
helm repo add aws-cloud-controller-manager https://kubernetes.github.io/cloud-provider-aws
helm repo update
helm upgrade --install aws-cloud-controller-manager aws-cloud-controller-manager/aws-cloud-controller-manager
EOF