explanation of the scripts involved (to be latter added) in here.
they could all be deployed via ansible roles and playbooks. and save the mess of bash scripts, transforming to declarative. 

order of script wrapping:
TF_apply.sh parent of these scripts:     
# ipcollecter.sh
  - collects ip's from terraform and injects them into ansible hosts file
# kubespraying.sh
  - adds dependencies for ansible and injects ip's to kubespray inventory
# updatehosts.sh
  - update the hosts file of kubespray with all relevant 3rd party such as flannel, metrics, nginx etc
# cloud provider install
  - bash script to install AWS cloud provider into kubespray for it to reference the cloud, and allow ASG(auto scaling groups) for autoscaling feature, not working.
  - the AWS CCM (cloud controller manager) conflicts with kubespray version. but the cluster does recognize AWS resources.
# install_argocd.sh
  - installs argocd on the cluster of kubespray via curl.
# install prometheus.sh
  - installs prometheus and grafana on the cluster for visibility and monitoring, via helm.
 
