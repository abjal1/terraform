# terraform

Ref: 1). https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-deploy-an-EKS-cluster-using-Terraform
     2). https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/eks-getting-started/eks-cluster.tf

# after cluster creation, run below command to update kube config.
aws eks update-kubeconfig --region us-east-1 --name test-eks-cluster

# if you see below error while running 'kubectl get nodes' command, then there is a issue with kubectl version. to fix this issue install below kubectl version.

error: error: exec plugin: invalid apiVersion "client.authentication.k8s.io/v1alpha1"

fix: curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
     chmod 777 /usr/local/bin/kubectl 
