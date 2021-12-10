output "DNS_address" {
    value = aws_elb.elb.dns_name
}