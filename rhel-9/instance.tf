provider "aws" {
  region = "us-east-1"
}

//


resource "aws_instance" "ami-instance" {
  ami                         = "ami-0874aa40645e0545d"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = ["sg-0a5363a31d93307b0"]
  #key_name                    = "DevOps321"

  tags = {
    Name = "rhel-9-ami"
  }
}

resource "terraform_data" "ami-create-apply" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.ami-instance.public_ip
      # user      = "ec2-user"
      # host      = aws_instance.ami-instance.public_ip
      #private_key = file("~/devops.pem")
    }

    inline = [
      "sudo yum install git -y",
      "cd /tmp && rm -rf aws-image-devops-session && git clone https://github.com/learndevopsonline/aws-image-devops-session.git",
      "cd aws-image-devops-session/rhel-9",
      "sudo bash ami-setup.sh",
      "cd /tmp && rm -rf /tmp/aws-image-devops-session",
      "sudo bash aws.sh",
    ]
  }
}

resource "aws_ami_from_instance" "ami" {
  depends_on                      = [terraform_data.ami-create-apply]
  name                            = "Vignesh-RHEL-9-DevOps-Practice"
  source_instance_id              = aws_instance.ami-instance.id
  tags                            = {
    Name                          = "Vignesh-RHEL-9-DevOps-Practice"
  }
}

resource "terraform_data" "public-ami" { 
    provisioner "local-exec" {
    command =<<EOF
aws ec2 modify-image-attribute --image-id ${aws_ami_from_instance.ami.id} --launch-permission "Add=[{Group=all}]" --region us-east-1
EOF
  }
}

