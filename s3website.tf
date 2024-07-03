resource "aws_s3_bucket" "s3website" {
  bucket = var.website_bucket
}

resource "aws_s3_bucket_acl" "s3website_acl" {
  bucket     = aws_s3_bucket.s3website.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.bucket_access_block]
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.s3website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "s3website_config" {
  bucket = aws_s3_bucket.s3website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "s3website_cors" {
  bucket = aws_s3_bucket.s3website.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_policy" "s3website_policy" {
  bucket     = aws_s3_bucket.s3website.id
  policy     = data.aws_iam_policy_document.s3website_policy_doc.json
  depends_on = [aws_s3_bucket_public_access_block.bucket_access_block]
}

data "aws_iam_policy_document" "s3website_policy_doc" {
  statement {
    sid    = "PublicGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.s3website.arn,
      "${aws_s3_bucket.s3website.arn}/*",
    ]
  }
}

resource "aws_s3_object" "main_file" {
  bucket       = aws_s3_bucket.s3website.id
  key          = "index.html"
  source       = "${path.module}/app/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "js_file" {
  bucket       = aws_s3_bucket.s3website.id
  key          = "demobuilder.js"
  source       = "${path.module}/app/demobuilder.js"
  content_type = "text/javascript"
}

