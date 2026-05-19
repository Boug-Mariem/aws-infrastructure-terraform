data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id  # image ubuntu
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  iam_instance_profile        = "LabInstanceProfile"  #donner des permissions IAM à l’EC2.

  user_data = base64encode(templatefile("${path.module}/userdata_frontend.sh", {
    alb_dns_name         = aws_lb.app_alb.dns_name
    github_token         = var.github_token
    github_frontend_repo = var.github_frontend_repo
  }))

  depends_on = [aws_lb_listener.http]
  tags       = { Name = "frontend-ec2" }
}