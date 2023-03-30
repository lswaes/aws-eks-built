// authorize terraform to access Kubernetes API and modify aws-auth configmap. To do that, you need to define terraform kubernetes provider
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster" "default" {
  name = module.eks.cluster_id
  # depends_on = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
  # depends_on = [module.eks.cluster_id]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)

  // You can either use TOKEN, or EXEC to authenticate with the cluster

  # token                  = data.aws_eks_cluster_auth.default.token  // >> has expiration time

  exec { // >> retrieve token on each tf run
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
  # depends_on = [module.eks.cluster_id]
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = "my-eks-1"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    jenkins-nexus = {
      desired_size = 1
      min_size     = 0
      max_size     = 3

      labels = {
        role = "jenkins-nexus"
      }

      taint = [{
        effect = "PREFER_NO_SCHEDULE"
        key    = "role"
        value  = "jenkins-nexus"
      }]

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    jekins_agent = {
      desired_size = 1
      min_size     = 0
      max_size     = 3

      labels = {
        role = "jenkins-agent"
      }

      taints = [{
        key    = "role"
        value  = "jenkins-agent"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "staging"
  }

  //To add the eks-admin IAM role to the EKS cluster, we need to update the aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name // "eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.eks_view_eks_role.iam_role_arn
      username = module.eks_view_eks_role.iam_role_name // "eks-view"
      groups   = ["developer"]
    },
  ]
  // later on -- add somemore
}

