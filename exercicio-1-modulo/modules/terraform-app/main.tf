data "aws_ami" "slacko-app" {
  most_recent = true
  owners = ["amazon"]
  
  filter {
   name = "name"
   values = ["Amazon*"]
}
  filter {
   name = "architecture"
   values= ["x86_64"]
}

}

data "aws_subnet" "subnet_public" { 
  cidr_block = var.subnet_cidr
}

resource "aws_key_pair" "slacko-sshkey" {
     key_name = format("%s-slacko-app-key", var.name_prefix)
     public_key = var.slacko-sshkey # gerando a chave publica ssh-keygen -C comentario -f slacko

}

resource "aws_instance" "slacko-app" {
   ami = data.aws_ami.slacko-app.id
   instance_type ="t2.micro"
   subnet_id = data.aws_subnet.subnet_public.id
   associate_public_ip_address = true

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-slacko-app", var.name_prefix)
            })
  key_name = aws_key_pair.slacko-sshkey.id ## quando referencia outro recurso que criou
  user_data_base64 = "IyEgL2Jpbi9iYXNoCnl1bSB1cGRhdGUKYW1hem9uLWxpbnV4LWV4dHJhcyBpbnN0YWxsIGRvY2tlcgpzZXJ2aWNlIGRvY2tlciBzdGFydAp1c2VybW9kIC1hIC1HIGRvY2tlciBlYzItdXNlcgpkb2NrZXIgcnVuIC0tcmVzdGFydCBhbHdheXMgLXAgODA6ODAwMCBsZW9uYXJkb2RnMjA4NC9za2Fja28tYXBpOjEuMC4w"  

}


resource "aws_instance" "mongodb" {

   ami = data.aws_ami.slacko-app.id
   instance_type ="t2.micro"
   subnet_id = data.aws_subnet.subnet_public.id

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-mongodb", var.name_prefix)
            })
  
  key_name = aws_key_pair.slacko-sshkey.id ## quando referencia outro recurso que criou
  user_data_base64 = "IyEgL2Jpbi9iYXNoCnl1bSB1cGRhdGUKYW1hem9uLWxpbnV4LWV4dHJhcyBpbnN0YWxsIGRvY2tlcgpzZXJ2aWNlIGRvY2tlciBzdGFydAp1c2VybW9kIC1hIC1HIGRvY2tlciBlYzItdXNlcgpkb2NrZXIgcnVuIC1wIDI3MDE3OjI3MDE3IC0tbmFtZSBzbGFja28tbW9uZ29kYiAtZCBtb25nbzo1LjAuMg=="

}

resource "aws_security_group" "allow-slacko" {
  name        =  format("%s-allow-ssh-http", var.name_prefix)
  description = "Allow ssh and http port"
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
      from_port        = 80
      to_port          = 80
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
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self = null
    }
  ]

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-allow_ssh_http", var.name_prefix)
            })
}

resource "aws_security_group" "allow-mongodb" {
  name        = format("%s-allow-mongodb", var.name_prefix)
  description = "Allow mongodb"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "allow db port"
      from_port        = 27017
      to_port          = 27017
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
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self = null
    }
  ]

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-allow_mongodb", var.name_prefix)
            })
}

resource "aws_network_interface_sg_attachment" "mongodb-sg" {
  security_group_id    = aws_security_group.allow-mongodb.id
  network_interface_id = aws_instance.mongodb.primary_network_interface_id
}
resource "aws_network_interface_sg_attachment" "slacko-sg" {
  security_group_id    = aws_security_group.allow-slacko.id
  network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
  name = "iaac0506.com.br"
  vpc { vpc_id = var.vpc_id }
}
resource "aws_route53_record" "mongodb" {
  zone_id = aws_route53_zone.slack_zone.id
  name    = "mongodb.iaac0506.com.br"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mongodb.private_ip]
}


