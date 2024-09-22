# Módulo EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "jwt-validator-cluster"
  cluster_version = "1.30"

  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids  # Use subnet_ids aqui

  eks_managed_node_groups = {
    eks_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"  # AMI para EKS
      instance_types = ["t3.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  # Segurança do Cluster
  cluster_security_group_id = aws_security_group.eks_cluster_sg.id
}

# IAM Role para o Node Group
resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "ec2.amazonaws.com",      # EC2 como principal
            "eks.amazonaws.com"       # EKS como principal
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Políticas para o Node Group (EKS Worker, ECR e CNI)
resource "aws_iam_role_policy_attachment" "node_group_eks_worker_node_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_ec2_ecr_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_group_eks_cni_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Security Group para o EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = var.vpc_id
  name   = "eks-cluster-sg"

  # Permitir tráfego HTTPS do cluster (plano de controle) para os nós
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Insira o CIDR do plano de controle
  }

  # Permitir tráfego entre os nós e o plano de controle nas portas usadas pelo Kubernetes (1025-65535)
  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego de saída irrestrito
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para o Node Group
resource "aws_security_group" "node_group_sg" {
  vpc_id = var.vpc_id
  name   = "eks-node-group-sg"

  # Permitir tráfego HTTPS entre o plano de controle e os nós
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir comunicação entre os nós nas portas usadas pelo Kubernetes (1025-65535)
  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego para a aplicação na porta 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego de saída irrestrito
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Relacionar o Security Group do Node Group ao Security Group do Cluster
resource "aws_security_group_rule" "node_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node_group_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}