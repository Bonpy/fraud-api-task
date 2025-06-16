data "aws_kinesis_stream" "this" {
  name = var.stream_name
}
