resource "aws_security_group" "ami_sg" {
  name        = "var.sg_ami"
  description = "Allow TLS inbound traffic for ${var.sg_ami}"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
}


resource "aws_instance" "ami-instance" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ami_sg.id]
  key_name                    = "devops"

  tags = {
    Name = "rhel-10-ami"
  }
}

resource "terraform_data" "ami-create-apply" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      #password = "DevOps321"
      host     = aws_instance.ami-instance.public_ip
      private_key = file("C:/Users/vigne/Downloads/devops.pem")
    }

    inline = [
      "sudo yum install git -y",
      "cd /tmp && rm -rf AWS-AMI && git clone https://github.com/leela-vigneswar/AWS-AMI.git",
      "cd AWS-AMI/rhel-10",
      "sudo bash ami-setup.sh",
      "cd /tmp && rm -rf /tmp/AWS-AMI",
    ]
  }
}

resource "aws_ami_from_instance" "ami" {
  depends_on                      = [terraform_data.ami-create-apply]
  name                            = var.ami_name
  source_instance_id              = aws_instance.ami-instance.id
  tags                            = {
    Name                          = var.ami_name
  }
}

resource "terraform_data" "public-ami-access" { 
    provisioner "local-exec" {
    command = "aws ec2 disable-image-block-public-access --region us-east-1"  
  }
}

resource "terraform_data" "public-ami" { 
    depends_on = [terraform_data.public-ami-access]  
    provisioner "local-exec" { 
    command = "aws ec2 modify-image-attribute --image-id ${aws_ami_from_instance.ami.id} --launch-permission Add=[{Group=all}] --region us-east-1"  

  }
}