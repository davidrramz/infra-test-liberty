resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name   = join("-", [local.solution_name, "key-pair", "ec2"])
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "liberty.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  for_each = toset(["master", "node1", "node2"])

  name = "instance-${each.key}"

  ami                    = data.aws_ami.amazon-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_key.key_name
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  subnet_id              = aws_subnet.web-subnet.id
  user_data              = file("install.sh")

  tags = {
    Terraform = "true"
  }
}

resource "null_resource" "InitMaster" {
    depends_on = [module.ec2_instance["master"]]

    triggers = {
    wait = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }


    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.ec2_key.private_key_pem
      host = module.ec2_instance["master"].public_ip
    }

    
    provisioner "remote-exec" {
    inline = [
      "output=$(docker swarm init --advertise-addr ${module.ec2_instance["master"].private_ip} 2>&1)",
      "echo $output > init_output.txt",
      "export join_command=$(grep -oP '(?<=docker swarm join --token )[^ ]+' init_output.txt)",
      "echo 'docker swarm join --token' $join_command ${module.ec2_instance["master"].private_ip}':2377' > init_output.txt"
    ]
  }
   provisioner "local-exec" {
    command = <<-EOT
    scp -o StrictHostKeyChecking=no -i ${local_file.ssh_key.filename} ec2-user@${module.ec2_instance["master"].public_ip}:~/init_output.txt ./ 
    EOT
  }
}

resource "null_resource" "JoinSwarm" {
  for_each = {
    for idx, instance in module.ec2_instance : idx =>
    instance
    if idx != "master"
  }

  
    depends_on = [null_resource.InitMaster]


    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.ec2_key.private_key_pem
      host = module.ec2_instance[each.key].public_ip
    }

    provisioner "local-exec" {
    command = <<-EOT
    scp -o StrictHostKeyChecking=no -i ${local_file.ssh_key.filename} init_output.txt  ec2-user@${module.ec2_instance[each.key].public_ip}:~/ 
    EOT
  }


     provisioner "remote-exec" {
    inline = [
      "join_command=$(cat init_output.txt)",
      "$join_command"
    ]
    }
}