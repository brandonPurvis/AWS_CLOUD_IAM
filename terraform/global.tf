provider "aws" {
  version = "~> 2.0"
}

// Contributor

data "aws_iam_policy_document" "contributor-policy-document" {
  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "contributor-assume-role-document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }
}

resource "aws_iam_policy" "contributor-policy" {
  name = "My-Contributor-Policy"
  description = "Permit actions for contributors."
  policy = "${data.aws_iam_policy_document.contributor-policy-document.json}"
}

resource "aws_iam_role" "contributor-role" {
  name = "My-Contributor-Role"
  assume_role_policy = "${data.aws_iam_policy_document.contributor-assume-role-document.json}"
}

resource "aws_iam_role_policy_attachment" "contributor-attachement" {
  role= "${aws_iam_role.contributor-role.name}"
  policy_arn = "${aws_iam_policy.contributor-policy.arn}"
}

// Assumers Group

data "aws_iam_policy_document" "role-assumer-policy-document" {
  statement {
    effect = "Allow"
    actions = ["sts:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sts-assumer-policy" {
  name = "My-Role-Assumer-Policy"
  description = "Permit assumption of IAM Roles."
  policy = "${data.aws_iam_policy_document.role-assumer-policy-document.json}"
}

resource "aws_iam_group" "role-assumers-group" {
  name = "RoleAssumers"
}

resource "aws_iam_group_policy_attachment" "role-assumer-group-policy-attachment" {
  group = "${aws_iam_group.role-assumers-group.name}"
  policy_arn = "${aws_iam_policy.sts-assumer-policy.arn}"
}

// Terraform User

resource "aws_iam_user" "terraform-user" {
  name = "TerraformUser"
}

resource "aws_iam_user_group_membership" "add-terraform-user-to-groups" {
  user = "${aws_iam_user.terraform-user.name}"
  groups = [
    "${aws_iam_group.role-assumers-group.name}"
  ]
}

resource "aws_iam_access_key" "terrafrom-user-access-key" {
  user = "${aws_iam_user.terraform-user.name}"
  status = "Active"
}

resource "aws_secretsmanager_secret" "terraform-user-secret" {
  name = "user-secret/${aws_iam_access_key.terrafrom-user-access-key.id}"
  description = "IAM User Secret for ${aws_iam_user.terraform-user.name} key id ${aws_iam_access_key.terrafrom-user-access-key.id}"
}

resource "aws_secretsmanager_secret_version" "terraform-user-secret-version" {
  secret_id = "${aws_secretsmanager_secret.terraform-user-secret.arn}"
  secret_string = "${aws_iam_access_key.terrafrom-user-access-key.secret}"
}

// OUTPUT

output "terraform-user-access" {
  value = {
    "id" = "${aws_iam_access_key.terrafrom-user-access-key.id}"
  }
}