resource "aws_key_pair" "k8s_cluster_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
  tags = {
    Name        = "k8s-key"
    Environment = "test"
    Terraform   = "true"
  }
}

locals {
  k8s_name = "k8s_network"
}

# Create Virtual Private Cloud (VPC)
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = local.k8s_name
  }
}

# Create VPC Subnet
resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = local.k8s_name
    Type = "Public"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "k8s" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "igw-${local.k8s_name}"
  }
}

# Create Route Table
resource "aws_route_table" "k8s_rtb" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s.id
  }

  tags = {
    Name = "rt-${local.k8s_name}"
  }
}

# Create Route Table association for public VPC subnet
resource "aws_route_table_association" "rta_k8s_subnet" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rtb.id
}

# Create EIP for Controller
resource "aws_eip" "controller" {
 instance = aws_instance.controller.id
}

# Create EIP for Workers
resource "aws_eip" "workers" {
  count = var.worker_count
  instance = aws_instance.workers[count.index].id
}

# Launch EC2 instances
resource "aws_instance" "controller" {
  ami                  = data.aws_ami.image.id
  instance_type        = "t2.medium"
  key_name             = var.key_pair_name
  ebs_optimized        = false
  hibernation          = false
  iam_instance_profile = aws_iam_instance_profile.assume_instance_profile.id
  user_data_base64     = base64gzip(file("${path.module}/files/bootstrap.sh"))
  monitoring           = false
  tenancy              = "default"

  subnet_id                   = aws_subnet.k8s_subnet.id

  vpc_security_group_ids = [aws_security_group.master.id]
  #security_groups = [aws_security_group.allow_tls_http_ssh.id]


  tags = {
    Name      = "k8s-controller"
    terraform = "true"
    project   = "kube-auto"
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    encrypted             = true
    kms_key_id            = "arn:aws:kms:us-east-1:235897040954:key/fbb4742c-8f85-486d-82b7-33188f1638a0"
    volume_type           = "gp3"
  }
}

resource "aws_instance" "workers" {
  count                = var.worker_count
  ami                  = data.aws_ami.image.id
  instance_type        = "t2.medium"
  key_name             = var.key_pair_name
  ebs_optimized        = false
  hibernation          = false
  iam_instance_profile = aws_iam_instance_profile.assume_instance_profile.id
  user_data_base64     = base64gzip(file("${path.module}/files/bootstrap.sh"))
  monitoring           = false
  tenancy              = "default"

  subnet_id                   = aws_subnet.k8s_subnet.id

  vpc_security_group_ids = [aws_security_group.worker_node.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  maintenance_options {
    auto_recovery = "default"
  }

  tags = {
    Name      = "k8s-worker-${count.index + 1}"
    terraform = "true"
    project   = "kube-auto"
  }
  volume_tags = {
    Name      = "k8s-worker-${count.index + 1}-volume"
    terraform = "true"
    project   = "kube-auto"
  }
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    encrypted             = true
    kms_key_id            = "arn:aws:kms:us-east-1:235897040954:key/fbb4742c-8f85-486d-82b7-33188f1638a0"
    volume_type           = "gp3"
  }
}