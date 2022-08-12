# terraform

Ref: 1). https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-deploy-an-EKS-cluster-using-Terraform
     2). https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/eks-getting-started/eks-cluster.tf

# after cluster creation, run below command to update kube config.
aws eks update-kubeconfig --region us-east-1 --name test-eks-cluster

# if you see below error while running 'kubectl get nodes' command, then there is a issue with kubectl version. to fix this issue install below kubectl version.

error: error: exec plugin: invalid apiVersion "client.authentication.k8s.io/v1alpha1"

fix: curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
     chmod 777 /usr/local/bin/kubectl 

# To deploy metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# To deploy nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml

# To get metrics of node
kubectl top node ip-10-0-3-16.ec2.internal

# Deploy pod and expose using service type load balancer
kubectl run --image=nginx nginx
kubectl expose pod nginx --port=80 --target-port=80 --type=loadBalancer

# To check the issue
kubectl describe pod pod-name
kubectl describe node node-name
