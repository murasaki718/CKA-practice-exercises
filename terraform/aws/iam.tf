resource "aws_iam_role" "assume_role" {
  description           = "Managed by Terraform"
  force_detach_policies = false
  name                  = "${local.k8s_name}-assume-role"
  path                  = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF

  tags = {
  }
}

resource "aws_iam_policy" "ec2_describe_tags" {
  description = "Managed by Terraform"
  name        = "${local.k8s_name}ec2-describe-tags"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeTags",
      "Resource": "*"
    }
  ]
}
  EOF
}

resource "aws_iam_instance_profile" "assume_instance_profile" {
  name = "us-cc"
  path = "/"
  role = aws_iam_role.assume_role.name
}

resource "aws_iam_role_policy_attachment" "us-cc-ec2-describe-tags" {
  role       = aws_iam_role.assume_role.name
  policy_arn = aws_iam_policy.ec2_describe_tags.arn
}