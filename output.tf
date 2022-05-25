output "output_vpc" {
  value       = aws_vpc.new_vpc.id
  description = "My vpc id"

}

output "output_public_route_table" {
  value       = aws_route_table.my_public_route.id
  description = "My public route table"

}

output "output_private_route_table" {
  value       = aws_route_table.my_private_route.id
  description = "My private route table"

}
output "output_internet_gateway" {
  value       = aws_internet_gateway.my_gateway.id
  description = "My internet gateway id"

}

output "output_nat_gateway" {
  value       = aws_nat_gateway.my_nat.id
  description = "My nat gateway id"

}

output "output_public_subnet" {
  value       = aws_subnet.my_public_subnet.id
  description = "My public subnet id"

}

output "output_private_subnet" {
  value       = aws_subnet.my_private_subnet.id
  description = "My private subnet id"

}

output "output_private_instance" {
  value       = aws_instance.my_private_instance.public_ip
  description = "My private instance ip"

}

output "output_public_instance" {
  value       = aws_instance.my_public_instance.public_ip
  description = "My public instance ip"

}

output "aip" {
  value       = aws_eip.my_elastic_ip.public_ip
  description = "My elastic ip"
}

