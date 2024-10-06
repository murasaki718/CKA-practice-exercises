output "controller_public_ip" {
  value = aws_instance.controller.public_ip
}

output "worker_public_ip" {
  value = aws_instance.workers[*].public_ip
}