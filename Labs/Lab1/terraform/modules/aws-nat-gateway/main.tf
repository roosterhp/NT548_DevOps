################################################################################
# NAT Gateway
################################################################################
locals {
  
  nat_gateway_ips   = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat_eip[*].id
}
resource "aws_eip" "nat_eip" {
  count = var.single_nat_gateway ? 1 : length(var.azs)

  domain = "vpc"

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )

  
}


resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? 1 : length(var.azs)

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    var.public_subnet_ids,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  
}

