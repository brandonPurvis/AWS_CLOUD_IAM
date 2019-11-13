provider "aws" {
  version = "~> 2.0"
}


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
      identifiers = ["arn:aws:iam::*:user/*"]
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
  assume_role_policy = "${data.aws_iam_policy_document.contributor-assume-role-document}"
}


resource "aws_iam_role_policy_attachment" "contributor-attachement" {
  role= "${aws_iam_role.contributor-role.name}"
  policy_arn = "${aws_iam_policy.contributor-policy.arn}"
}