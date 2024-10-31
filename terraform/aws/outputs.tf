output "controller_node_public_ip" {
  value = module.controller[*].public_ip
}

output "worker_node_public_ip" {
  value = module.worker_nodes[*].public_ip
}