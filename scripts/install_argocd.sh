#!/bin/bash
# ip of machine to connect to
cd ..
MASTER_K8S_IP_PUB=$(terraform output -raw  master_ip_pub)
echo "#pass the ingress-rule for argo cd to : ${MASTER_K8S_IP_PUB}"
ssh-keyscan  -H $MASTER_K8S_IP_PUB >> ~/.ssh/known_hosts
echo " copying ingress rule argocd"
cd scripts
scp  ingress-rule-argo.yaml ubuntu@$MASTER_K8S_IP_PUB:~
# install argoCD as argocd.grad.arieldevops.tech
ssh  ubuntu@$MASTER_K8S_IP_PUB <<EOF
whoami
echo " namespacing argoCD"
sudo kubectl create ns argocd
echo " installing argoCD"
sudo curl -L https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | \
sudo sed '/- argocd-server/a \          - --insecure' | \
sudo kubectl apply -f - -n argocd


echo "end install"

echo "applying argocd ingress rule"

sudo kubectl apply -f ingress-rule-argo.yaml -n argocd
echo "patching argo cd deployment for dns zone"
sudo kubectl patch deployment argocd-server -n argocd --type=json -p='[
    {
        "op": "add",
        "path": "/spec/template/spec/containers/0/args/-",
        "value": "--insecure"
    }
]'



echo "# Install Argo CD CLI"
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "# Set the password environment variable"
export ARGOCD_PASS=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

echo " # Define variables"
ARGOCD_SERVER="argocd.grad.arieldevops.tech" # Removed /argocd
USERNAME="admin"
PASSWORD=$ARGOCD_PASS  # Use the environment variable

echo "# Login (removed sudo)"
argocd login $ARGOCD_SERVER --username $USERNAME --password $PASSWORD --insecure

echo "# Deploy an application (removed sudo, fixed the command continuation)"
argocd app create my-app \
  --repo https://github.com/meditator3/react-java-mysql.git \
  --path manifest \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace react \
  --sync-policy automated 
echo " end deployment by argocd"
exit
EOF