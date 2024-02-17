#!/bin/bash
# ip of the machine to install prometheus
MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)

# copy helm values chart to machine that installs prometheus
scp  values-ariel.yaml ubuntu@$MASTER_K8S_IP_PUB:~   # updated helm values for ingress deployment
scp LB-ingress.yaml ubuntu@$MASTER_K8S_IP_PUB:~    # LB svc for aws

# ssh to machine
ssh  ubuntu@$MASTER_K8S_IP_PUB <<EOF
whoami
# apply LB-ingress rule 
sudo kubectl apply -f LB-ingress.yaml
# download and configure helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

# update repo for prometheus and grafana and
sudo helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo  helm repo add stable https://charts.helm.sh/stable
sudo helm repo add grafana https://grafana.github.io/helm-charts
sudo helm repo update
# create NS monitoring
sudo kubectl create ns monitoring
  # # using values-ariel.yaml to install prometheus grafana  # #
echo " starting prometheus stack installing via helm"  
sudo cp values-ariel.yaml /root/values-ariel.yaml
sudo helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring -f values-ariel.yaml
sudo kubectl get secret --namespace monitoring kube-prom-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

EOF
