output "ecr_push_role_arn" {
  value = aws_iam_role.ecr_push.arn
}

output "terraform_role_arn" {
  value = aws_iam_role.terraform.arn
}