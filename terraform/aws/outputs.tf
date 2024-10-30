output "controller_node_public_ip" {
  value = aws_instance.controller[*].public_ip
}

output "worker_node_public_ip" {
  value = aws_instance.nodes[*].public_ip
}