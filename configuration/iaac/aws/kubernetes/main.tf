# Script for provisioning/creating kubernetes cluster
# aws --version
# aws eks --region us-east-1 update-kubeconfig --name in28minutes-cluster
# Uses default VPC and Subnet. Create Your Own VPC and Private Subnets for Prod Usage.
# S3 bucket ARN : arn:aws:s3:::terraform-backend-state-sonymathew
# S3 bucket name : terraform-backend-state-sonymathew
<<<<<<< HEAD
# cmd line user access id: AKIASQFSB4RYQG36WQSB
=======
# sonymathew_dev user access id: AKIASQFSB4RYSVR3TPBG
>>>>>>> a93f6ac928e88228dd7c926ab4ae5c0ce850c253
# Defsult vpc : aws -> services -> vpc -> default vpc is teh one ithout a name -> copy id -> vpc-eec60593
# subnet -> go to defaulr vpc ( refer above) -> select it -> select subnets from the left tab under 'virtual private cloud' 
# subnet ids -> subnet-d58c3ef4, subnet-84b80fe2



terraform {
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "sonymathew-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "sonymathew-cluster"
<<<<<<< HEAD
  cluster_version = "1.15"
  subnets         = ["subnet-05ac1c5a", "subnet-5c7f3811"] #CHANGE
=======
  cluster_version = "1.14"
  subnets         = ["subnet-d58c3ef4", "ubnet-84b80fe2"] #CHANGE
>>>>>>> a93f6ac928e88228dd7c926ab4ae5c0ce850c253
  #subnets = data.aws_subnet_ids.subnets.ids
  vpc_id          = aws_default_vpc.default.id

  #vpc_id         = "vpc-eec60593"

  node_groups = [
    {
      instance_type = "t2.micro"
      max_capacity  = 5
      desired_capacity = 3
      min_capacity  = 3
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.sonymathew-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.sonymathew-cluster.cluster_id
}


# We will use ServiceAccount to connect to K8S Cluster in CI/CD mode
# ServiceAccount needs permissions to create deployments 
# and services in default namespace
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "fabric8-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}

# Needed to set the default region
provider "aws" {
  region  = "us-east-1"
}