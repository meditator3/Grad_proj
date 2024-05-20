# Grad_proj
terraform-ansible-kubespray-cluster deployment of a complete CI-CD process over a react App.
----------------------------------------------------------------------------------------------

this deploys with terraform AWS resources  to create an ansible-kubespray created kubernetes cluster, at the AWS cloud.


the scripts folder, are the key to succesful wrapping and installing of all addons.


addons included:

argocd
prometheus-grafana
cert manager
Cluster autoscaler
AWS cloud controller manager
Metrics server

![Capture](https://github.com/meditator3/Grad_proj/assets/22438413/0ae04b26-bf49-45d9-981c-a82b302cf2a3)


CI
---
CI is being run by a self hosted runner on AWS(couldn't pass the steps conditionals to next steps, bug?)
once the images are pushed after versioning update in the repo of the App itself(react-java0mysql), 
a folder manifests updates its yamls via SED. to the newer version. 


CD
--
because argoCD can sense changes in the App repo, with the new update, that was made via SED over at the manifests-
it syncs the cluster with the new images automatically, and deploys the new version from the Tag and registery of docker hub, in this case.
which means the github repo is actually being code changed(actual git puhs/commit commands from the git action CI), and PR/commit is being made to the repo, because of the updated manifests of the repo.

Terraform
---
terraform is workflow dispatch(manual triggering), for creating all cloud resources, and also the wrappers for creating the cluster on all its 3rd party
and it proper configurations. for example, for the LB to work the AWS CCM(cloud controller manager) had to know the node's name, which was outputed via outputs/TF.

