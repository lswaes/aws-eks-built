resource "aws_s3_bucket" "loki_object_store" {
  bucket = "sam-s3-loki-dev-01"
      
  tags = {
    Name        = "dev-loki"
    environment = "dev"
  }   
}

resource "aws_s3_bucket_acl" "loki_object_store_acl" {
  bucket = aws_s3_bucket.loki_object_store.id
  acl    = "private"
}

module "s3-loki-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "s3-loki-policy-1"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::s3-loki-dev-01",
          "arn:aws:s3:::s3-loki-dev-01/*"
        ]
      },
    ]
  })
}

module "loki-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name = "loki-role-with-oidc-1"

  tags = {
    Role = "loki"
  }

  # provider_url = "arn:aws:iam::812192580694:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/E358E2AD245CD97BD0082966B97EAA65" // oidc of eks
  provider_url = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
  oidc_fully_qualified_subjects = ["sts.amazonaws.com"]
  role_policy_arns = [
    module.s3-loki-policy.arn
  ]
  number_of_role_policy_arns = 1
}