resource "aws_s3_bucket" "this" {
  bucket = "dct-aws-cloud-labs-jordi-casanella"

  tags = {
    Name = "AmazonLinux Terraform"
  }
}

resource "aws_s3_bucket_object" "this" {
  for_each = fileset("uploads/", "*")
  bucket   = aws_s3_bucket.this.id
  key      = each.value
  source   = "uploads/${each.value}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("uploads/${each.value}")
}
