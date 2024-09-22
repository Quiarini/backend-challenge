resource "aws_iam_role" "eks_role" {
  name               = "jwt-validator-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "eks_policy_attachment" {
  name       = "jwt-validator-cluster-policy-attachment"
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Criar uma nova política para o Node
resource "aws_iam_policy" "eks_node_policy" {
  name        = "jwt-validator_node_policy"
  description = "Política que permite as ações necessárias para os nós do EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateTags",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "eks:DescribeCluster",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

# Definindo a política de confiança
data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "eks.amazonaws.com"]
    }
  }
}

# Criar a IAM Role para o Node Group
resource "aws_iam_role" "eks_node_role" {
  name               = "jwt-validator-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
}

# Associar a nova política à Role do Node
resource "aws_iam_policy_attachment" "node_policy_attachment" {
  name       = "jwt-validator-node-policy-attachment"
  roles      = [aws_iam_role.eks_node_role.name]
  policy_arn = aws_iam_policy.eks_node_policy.arn
}

output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn  # Certifique-se de que essa linha é válida
}