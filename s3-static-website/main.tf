resource "aws_s3_bucket" "static_web" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "static_web" {
  bucket = aws_s3_bucket.static_web.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_web" {
  bucket = aws_s3_bucket.static_web.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_web.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.static_web.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [aws_s3_bucket_public_access_block.static_web]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_web.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.static_web.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "profile" {
  bucket       = aws_s3_bucket.static_web.id
  key          = "lily.png"
  source       = "lily.png"
  content_type = "image/png"
}

resource "aws_s3_bucket_website_configuration" "static_web" {
  bucket = aws_s3_bucket.static_web.id

  index_document { suffix = "index.html" }
  error_document { key    = "error.html"  }
}
