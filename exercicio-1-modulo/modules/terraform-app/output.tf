output "slacko-app-name-output" {
  value       = "${lookup(aws_instance.slacko-app.tags, "Name")}"
  description = "Nome do APP"
}

output "slacko-mongodb-output" {
  value       = "${lookup(aws_instance.mongodb.tags, "Name")}"
  description = "Nome do MongoDB"
}

output "slacko-allow-slacko-output" {
  value       = "${lookup(aws_security_group.allow-slacko.tags, "Name")}"
  description = "Nome do security group APP"
}

output "slacko-allow-mongodb-output" {
  value       = "${lookup(aws_security_group.allow-mongodb.tags, "Name")}"
  description = "Nome do security group mongodb"
}