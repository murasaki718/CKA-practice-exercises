output "nodes_public_ip" {
  value = {
    Controller = try(module.controller.public_ip, null)
    Workers = try(module.worker_nodes[*].public_ip, null)
  }
}