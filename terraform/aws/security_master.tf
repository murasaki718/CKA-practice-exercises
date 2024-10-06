# Create security group for Master
resource "aws_security_group" "master" {
  name   = "k8s-master-sg"
  vpc_id = aws_vpc.k8s_vpc.id

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "API Server"
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ETCD"
    protocol    = "tcp"
    from_port   = 2379
    to_port     = 2380
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API, Kube-scheduler, Kube-controller-manager"
    protocol    = "tcp"
    from_port   = 10248
    to_port     = 10260
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort Service"
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-master-${local.k8s_name}"
  }
}