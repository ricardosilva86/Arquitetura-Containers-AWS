locals {
  vpc_cidr         = "10.0.0.0/16"
  internet_gw_name = format("%s-igw", var.project_name)

  # This local variable defines the subnets for the VPC.
  # Each subnet has properties such as NAT and internet enablement,
  # availability zone, CIDR block, and a tag name.
  subnets = tomap({
    "private_subnet_1a" = {
      nat_enabled             = true
      internet_enabled        = false
      az_private_subnet       = format("%sa", var.region)
      az_private_subnet_cidr  = "10.0.0.0/20"
      private_subnet_tag_name = format("%s-private-subnet-1a", var.project_name)
    }
    "private_subnet_1b" = {
      nat_enabled             = true
      internet_enabled        = false
      az_private_subnet       = format("%sb", var.region)
      az_private_subnet_cidr  = "10.0.16.0/20"
      private_subnet_tag_name = format("%s-private-subnet-1b", var.project_name)
    }
    "private_subnet_1c" = {
      nat_enabled             = true
      internet_enabled        = false
      az_private_subnet       = format("%sc", var.region)
      az_private_subnet_cidr  = "10.0.32.0/20"
      private_subnet_tag_name = format("%s-private-subnet-1c", var.project_name)
    }
    "public_subnet_1a" = {
      nat_enabled             = false
      internet_enabled        = true
      az_private_subnet       = format("%sa", var.region)
      az_private_subnet_cidr  = "10.0.48.0/24"
      private_subnet_tag_name = format("%s-public-subnet-1a", var.project_name)
    }
    "public_subnet_1b" = {
      nat_enabled             = false
      internet_enabled        = true
      az_private_subnet       = format("%sb", var.region)
      az_private_subnet_cidr  = "10.0.49.0/24"
      private_subnet_tag_name = format("%s-public-subnet-1b", var.project_name)
    }
    "public_subnet_1c" = {
      nat_enabled             = false
      internet_enabled        = true
      az_private_subnet       = format("%sc", var.region)
      az_private_subnet_cidr  = "10.0.50.0/24"
      private_subnet_tag_name = format("%s-public-subnet-1c", var.project_name)
    }
    "database_subnet_1a" = {
      nat_enabled             = false
      internet_enabled        = false
      az_private_subnet       = format("%sa", var.region)
      az_private_subnet_cidr  = "10.0.51.0/24"
      private_subnet_tag_name = format("%s-database-subnet-1a", var.project_name)
    }
    "database_subnet_1b" = {
      nat_enabled             = false
      internet_enabled        = false
      az_private_subnet       = format("%sb", var.region)
      az_private_subnet_cidr  = "10.0.52.0/24"
      private_subnet_tag_name = format("%s-database-subnet-1b", var.project_name)
    }
    "database_subnet_1c" = {
      nat_enabled             = false
      internet_enabled        = false
      az_private_subnet       = format("%sc", var.region)
      az_private_subnet_cidr  = "10.0.53.0/24"
      private_subnet_tag_name = format("%s-database-subnet-1c", var.project_name)
    }
  })

}

# This resource creates an AWS VPC with the specified CIDR block.
# It enables DNS support and DNS hostnames for the VPC.
# The VPC is tagged with the project name.
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.project_name
  }
}

# This resource creates AWS subnets within the specified VPC.
# It iterates over the subnets defined in the local variable `subnets`.
# Each subnet is assigned a CIDR block and an availability zone.
# The subnets are tagged with their respective names.
resource "aws_subnet" "main" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.az_private_subnet_cidr
  availability_zone = each.value.az_private_subnet
  tags = {
    Name = each.value.private_subnet_tag_name
  }
}

# This resource creates an AWS Internet Gateway and attaches it to the specified VPC.
# The Internet Gateway allows communication between the VPC and the internet.
# The Internet Gateway is tagged with the project name.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.internet_gw_name
  }
}

# This resource creates an Elastic IP (EIP) for each NAT-enabled subnet.
# The EIP is used to provide a static public IP address for the NAT Gateway.
# The EIP is tagged with the project name and the availability zone.
resource "aws_eip" "main" {
  for_each = { for key, val in local.subnets : key => val if val.nat_enabled == true }
  domain   = "vpc"

  tags = {
    Name = format("%s-%s-eip", var.project_name, replace(each.value.az_private_subnet, "eu-central-", ""))
  }
}

# This resource creates an AWS NAT Gateway for each NAT-enabled subnet.
# The NAT Gateway allows instances in the private subnets to connect to the internet
# or other AWS services, but prevents the internet from initiating connections with those instances.
# The NAT Gateway is associated with an Elastic IP (EIP) and is tagged with the project name
# and the availability zone.
resource "aws_nat_gateway" "ngw" {
  for_each      = { for key, val in local.subnets : key => val if val.nat_enabled == true }
  subnet_id     = aws_subnet.main[each.key].id
  allocation_id = aws_eip.main[each.key].id
  tags = {
    Name = replace(
      format(
        "%s-ngw-%s",
        var.project_name,
        aws_subnet.main[each.key].availability_zone
      ),
      "eu-central-",
    "")
  }
}

# This resource creates a public route table for the VPC.
# The route table is tagged with the project name.
resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = format("%s-public", var.project_name)
  }
}


# This resource creates a public route for the VPC.
# The route allows traffic to flow from the VPC to the internet.
# The route is associated with the public route table and the internet gateway.
resource "aws_route" "public_access" {
  route_table_id         = aws_route_table.main_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# This resource creates a private route tables for the VPC.
# The route table is tagged with the project name.
resource "aws_route_table" "main_private" {
  for_each = { for key, val in local.subnets : key => val if val.nat_enabled == true && val.internet_enabled == false }
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = format("%s-private", var.project_name)
  }
}

# This resource creates a private route for the VPC.
# The route allows traffic from the private subnets to the internet via the NAT Gateway.
# The route is associated with the private route table and the NAT Gateway.
resource "aws_route" "private_access" {
  for_each               = { for key, val in local.subnets : key => val if val.nat_enabled == true && val.internet_enabled == false }
  route_table_id         = aws_route_table.main_private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.ngw[each.key].id
}

# This resource associates the public route table with the public subnets.
# It iterates over the subnets defined in the local variable `subnets`.
# Each subnet that is not NAT-enabled and is internet-enabled will be associated with the public route table.
resource "aws_route_table_association" "public_route" {
  for_each       = { for key, val in local.subnets : key => val if val.nat_enabled == false && val.internet_enabled == true }
  route_table_id = aws_route_table.main_public.id
  subnet_id      = aws_subnet.main[each.key].id
}


# This resource associates the private route table with the private subnets.
# It iterates over the subnets defined in the local variable `subnets`.
# Each subnet that is NAT-enabled and not internet-enabled will be associated with the private route table.
resource "aws_route_table_association" "private_route" {
  for_each       = { for key, val in local.subnets : key => val if val.nat_enabled == true && val.internet_enabled == false }
  route_table_id = aws_route_table.main_private[each.key].id
  subnet_id      = aws_subnet.main[each.key].id
}

### PARAMETER STORE ###
# These resources creates AWS SSM parameters for the VPC,
# public subnets, private subnets, and database subnets.
resource "aws_ssm_parameter" "vpc" {
  name  = format("/%s/vpc/vpc-id", var.project_name)
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "private_subnets" {
  for_each = { for key, val in local.subnets : key => val if val.nat_enabled == true && val.internet_enabled == false }
  name = replace(
    format(
      "/%s/vpc/private-subnet-%s",
      var.project_name,
      aws_subnet.main[each.key].availability_zone
    ),
    "eu-central-",
    ""
  )
  type  = "String"
  value = aws_subnet.main[each.key].id
}

resource "aws_ssm_parameter" "public_subnets" {
  for_each = { for key, val in local.subnets : key => val if val.nat_enabled == false && val.internet_enabled == true }
  name = replace(
    format(
      "/%s/vpc/public-subnet-%s",
      var.project_name,
      aws_subnet.main[each.key].availability_zone
    ),
    "eu-central-",
    ""
  )
  type  = "String"
  value = aws_subnet.main[each.key].id
}

resource "aws_ssm_parameter" "database_subnets" {
  for_each = { for key, val in local.subnets : key => val if val.nat_enabled == false && val.internet_enabled == false }
  name = replace(
    format(
      "/%s/vpc/database-subnet-%s",
      var.project_name,
      aws_subnet.main[each.key].availability_zone
    ),
    "eu-central-",
    ""
  )
  type  = "String"
  value = aws_subnet.main[each.key].id
}