# # resource "aws_ecr_repository" "docker-repo" {
# #   name                 = "docker-repo"
# #   image_tag_mutability = "MUTABLE"

# #   tags = {
# #     Terraform   = "true"
# #     Environment = "dev"
# #   }
# # }

# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   name = "jump"

#   associate_public_ip_address = true
#   ami                         = "ami-0ecc74eca1d66d8a6"
#   instance_type               = "t2.medium"
#   monitoring                  = true
#   vpc_security_group_ids      = [module.bastion_ssh_sg.security_group_id]
#   subnet_id                   = module.vpc.public_subnets[0]
#   key_name                    = "terraform-pem"

#   user_data = <<-EOF
#     # TERRAFORM
#     #!/bin/bash
#     sudo su
#     sudo apt-get update && sudo apt-get install -y gnupg software-properties-common -y
#     wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
#     gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
#     echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#     sudo apt update
#     sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com buster main"
#     sudo apt-get install terraform -y

#     # KUBELET
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
#     sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#     # DOCKER
#     sudo apt-get update
#     sudo apt-get install ca-certificates curl gnupg lsb-release -y
#     sudo mkdir -p /etc/apt/keyrings
#     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#     sudo apt-get update
#     sudo chmod a+r /etc/apt/keyrings/docker.gpg
#     sudo apt-get update
#     sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

#     # AWS CLI
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#     unzip awscliv2.zip
#     sudo ./aws/install

#     # GIT
#     sudo apt install git -y

#   EOF

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }