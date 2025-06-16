variable "env" { type = string }
variable "kinesis_stream_name" { type = string }
variable "demographics_table_name" { type = string }

variable "model_name" { type = string }
variable "image_uri" { type = string }
variable "model_artifact_s3" { type = string }
variable "instance_type" {
  type    = string
  default = "ml.m5.large"
}
variable "initial_instance_count" {
  type    = number
  default = 1
}

variable "flink_application_name" { type = string }
variable "flink_runtime_env" {
  type    = string
  default = "FLINK-1_18"
}
variable "flink_code_s3_uri" { type = string }
variable "flink_checkpoint_s3_uri" { type = string }
variable "flink_sink_s3_uri" { type = string }
