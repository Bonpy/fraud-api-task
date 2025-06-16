variable "application_name" { type = string }
variable "runtime_env" { type = string }
variable "code_s3_uri" { type = string }
variable "kinesis_stream_arn" { type = string }
variable "checkpoint_s3_uri" { type = string }
variable "sink_s3_uri" { type = string }
variable "dynamodb_table_arn" { type = string }
variable "sagemaker_endpoint_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
