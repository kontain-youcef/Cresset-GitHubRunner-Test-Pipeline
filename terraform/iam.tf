data "aws_caller_identity" "this" {}

# Role that EC2 runners assume
resource "aws_iam_role" "runner" {
  name               = "gha-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

# Attach AWS-managed policy so runner has SSM agent capabilities
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom inline policy: allow EC2s to read the runner token from Parameter Store
resource "aws_iam_policy" "ssm_get_token" {
  name   = "gha-runner-ssm-get-token"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ssm:GetParameter"],
      Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.this.account_id}:parameter${var.runner_token_parameter_name}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm_get_token" {
  role       = aws_iam_role.runner.name
  policy_arn = aws_iam_policy.ssm_get_token.arn
}

# Instance profile so EC2 can assume the role
resource "aws_iam_instance_profile" "runner" {
  name = "gha-runner-instance-profile"
  role = aws_iam_role.runner.name
}
