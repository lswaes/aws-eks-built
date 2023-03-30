// this is for service account using IAM role
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks" {
  # client_id_list  = ["sts.amazonaws.com"]
  # thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}
