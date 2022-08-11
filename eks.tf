resource "aws_iam_role" "eks-iam-role" {
 name = "eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}



resource "aws_security_group" "eks-cluster-sg" {
  name        = "eks-cluster-sg"
  description = "Allow https traffic"
  vpc_id      = aws_vpc.eks-vpc.id

  ingress {
    description      = "Allow https traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}


resource "aws_eks_cluster" "test-eks-cluster" {
 name = "test-eks-cluster"
 role_arn = aws_iam_role.eks-iam-role.arn

 vpc_config {
  security_group_ids = [aws_security_group.eks-cluster-sg.id]
  subnet_ids = aws_subnet.eks-public-sub[*].id
 }

 depends_on = [
  aws_iam_role.eks-iam-role,
 ]
}

#managed-nodegroup.tf 

resource "aws_iam_role" "eks-nodegroup-iam-role" {
  name = "eks-nodegroup-iam-role"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.eks-nodegroup-iam-role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.eks-nodegroup-iam-role.name
 }
 
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks-nodegroup-iam-role.name
 }

resource "aws_eks_node_group" "worker-nodegroup" {
  cluster_name  = aws_eks_cluster.test-eks-cluster.name
  node_group_name = "worker-nodegroup"
  node_role_arn  = aws_iam_role.eks-nodegroup-iam-role.arn
  subnet_ids   = aws_subnet.eks-private-sub[*].id
  
  instance_types = ["t2.micro"]
 
  scaling_config {
   desired_size = 1
   max_size   = 1
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }
