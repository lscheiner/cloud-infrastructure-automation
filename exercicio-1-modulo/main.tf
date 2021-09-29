
variable "vpc_id"     { }
variable "subnet_cidr"     { }
variable "name_prefix"     { }
variable "app_tags"     { }
variable "slacko-sshkey"     { }



module "slacko-app" {
  source = "./modules/terraform-app"
  vpc_id = var.vpc_id
  subnet_cidr = var.subnet_cidr
  name_prefix = var.name_prefix
  app_tags = var.app_tags
  slacko-sshkey = var.slacko-sshkey
}

output "slacko-app-name" {
  value       = module.slacko-app.slacko-app-name-output
  description = "Nome do APP"
}

output "slacko-mongodb" {
  value       = module.slacko-app.slacko-mongodb-output
  description = "Nome do mongodb"
}

output "slacko-sg-app" {
  value       = module.slacko-app.slacko-allow-slacko-output
  description = "Nome do mongodb"
}

output "slacko-sg-mongodb" {
  value       = module.slacko-app.slacko-allow-mongodb-output
  description = "Nome do mongodb"
}