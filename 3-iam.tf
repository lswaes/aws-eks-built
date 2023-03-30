module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access-1"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin-1"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}
module "user1_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"

  name                          = "user1"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
}
module "user2_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"

  name                          = "user2"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
}
module "user3_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"

  name                          = "user3"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
}
module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-assume-eks-admin-iam-role-1"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })
}
module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  name                              = "eks-admin-1"
  attach_iam_self_management_policy = false
  create_group                      = true
  group_users = [
    module.user1_iam_user.iam_user_name,
    # module.user2_iam_user.iam_user_name
  ]
  custom_group_policy_arns = [module.allow_assume_eks_admins_iam_policy.arn]
}


module "allow_view_eks_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-view-eks-1"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:ListClusters",
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
module "eks_view_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "view-eks-1"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_view_eks_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root",
    "arn:aws:iam::812192580694:user/user2"
  ]
}
module "allow_assume_view_eks_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-assume-view-eks-iam-role-1"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_view_eks_role.iam_role_arn
      },
    ]
  })
}
module "eks_dev_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  name                              = "view-eks-1"
  attach_iam_self_management_policy = false
  create_group                      = true
  group_users = [
    # module.user1_iam_user.iam_user_name,
    module.user2_iam_user.iam_user_name,
    # module.user3_iam_user.iam_user_name
  ]
  custom_group_policy_arns = [module.allow_assume_view_eks_iam_policy.arn]
}
