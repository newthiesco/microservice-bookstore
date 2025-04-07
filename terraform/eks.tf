module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  # Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # VPC configuration
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # Node groups
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "t3.large"]
  }

  eks_managed_node_groups = {
    green = {
      use_custom_launch_template = false
      min_size                   = 1
      max_size                   = 10
      desired_size               = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # Optional: Fargate profile
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.34.0"

  depends_on = [module.eks]

  manage_aws_auth_configmap = true
  #eks_cluster_name          = module.eks.cluster_name

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::594182463744:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::594182463744:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::594182463744:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "594182463744",
    "888888888888",
  ]
}


