module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "sam-eks-1"
  cidr = "10.1.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.1.30.0/24", "10.1.31.0/24"]
  public_subnets  = ["10.1.20.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "staging"
  }
}

module "bastion_ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion_ssh_sg"
  description = "Security group for bastion"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp","http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

resource "aws_security_group" "sg_nodes" {
  name        = "sg_eks_nodes"
  description = "Allow internal traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}