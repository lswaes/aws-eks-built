resource "aws_eks_addon" "csi_driver" {
  cluster_name             = data.aws_eks_cluster.default.name
  addon_name               = "aws-ebs-csi-driver"
  // use this command to find out version of ebs driver
  // aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
  addon_version            = "v1.16.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}
