data "aws_ami" "jenkins" {
  most_recent = true
  owners = ["099720109477"]
  
  filter {
   name = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210430"]
}
  filter {
   name = "architecture"
   values= ["x86_64"]
}

}

data "aws_subnet" "subnet_public" { 
  cidr_block = var.subnet_cidr
}

resource "aws_key_pair" "jenkins-sshkey" {
     key_name = format("%s-jenkins-app-key", var.name_prefix)
     public_key = var.jenkins-sshkey # gerando a chave publica ssh-keygen -C comentario -f slacko

}

resource "aws_instance" "jenkins" {
connection {
        user = "ubuntu"
        host = "${self.public_ip}"
        type     = "ssh"
        private_key = "${file(var.private_key_path)}"
      }
   vpc_security_group_ids = [aws_security_group.allow-jenkins.id]
   ami = data.aws_ami.jenkins.id
   instance_type = var.instance_type
   subnet_id = data.aws_subnet.subnet_public.id
   associate_public_ip_address = true

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-jenkins-app", var.name_prefix)
            })
  key_name = aws_key_pair.jenkins-sshkey.id
  user_data_base64 = "IyEgL2Jpbi9iYXNoCnN1ZG8gYXB0LWdldCB1cGRhdGUKc3VkbyBhcHQgaW5zdGFsbCBvcGVuamRrLTExLWpkayAteQp3Z2V0IC1xIC1PIC0gaHR0cHM6Ly9wa2cuamVua2lucy5pby9kZWJpYW4tc3RhYmxlL2plbmtpbnMuaW8ua2V5IHwgc3VkbyBhcHQta2V5IGFkZCAtCnN1ZG8gc2ggLWMgJ2VjaG8gZGViIGh0dHBzOi8vcGtnLmplbmtpbnMuaW8vZGViaWFuLXN0YWJsZSBiaW5hcnkvID4gL2V0Yy9hcHQvc291cmNlcy5saXN0LmQvamVua2lucy5saXN0JwpzdWRvIGFwdC1nZXQgLW8gQWNxdWlyZTo6aHR0cHM6OnBrZy5qZW5raW5zLmlvOjpWZXJpZnktUGVlcj1mYWxzZSB1cGRhdGUKc3VkbyBhcHQtZ2V0IC1vIEFjcXVpcmU6Omh0dHBzOjpnZXQuamVua2lucy5pbzo6VmVyaWZ5LVBlZXI9ZmFsc2UgLW8gQWNxdWlyZTo6aHR0cHM6OnBrZy5qZW5raW5zLmlvOjpWZXJpZnktUGVlcj1mYWxzZSBpbnN0YWxsIGplbmtpbnMgLXkKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgamVua2lucw=="  
  provisioner "remote-exec" {
    inline = [
      "sleep 400",
      "echo \"Chave Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\""
    ]
 }
}

resource "aws_security_group" "allow-jenkins" {
  name        =  format("%s-allow-ssh-8080", var.name_prefix)
  description = "Allow ssh and 8080 port"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "allow ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self = null
    }, 
    {
      description      = "allow http"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self = null
    }

  ]

  egress = [ ## trafego de saida
    {
      description      = "saida"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = null
    }
  ]

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-allow_ssh_8080", var.name_prefix)
            })
}


