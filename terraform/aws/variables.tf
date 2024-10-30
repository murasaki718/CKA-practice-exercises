variable "aws_region" {
  type = string
}
variable "key_pair_name" {
  type    = string
  default = "k8s"
}
variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
variable "controller_node_count" {
  type = number
}
variable "worker_node_count" {
  type = number
}