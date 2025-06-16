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
variable "tags" {
  type    = map(string)
  default = {}
}
