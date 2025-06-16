variable "table_name" { type = string }
variable "partition_key" { type = string }
variable "stream_enabled" {
  type    = bool
  default = false
}
variable "tags" {
  type    = map(string)
  default = {}
}
