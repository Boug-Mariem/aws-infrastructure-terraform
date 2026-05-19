resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = "ami-0e1e769742d1cfb49" # image Linux
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(
    templatefile("${path.module}/compute/user_data.sh.tftpl", {
      repo_url    = var.github_backend_repo 
      repo_branch = "main"
      app_port    = 3000
      db_host     = aws_db_instance.mysql.address 
      db_user     = var.db_username
      db_password = var.db_password
      db_name     = var.db_name
    })
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
}