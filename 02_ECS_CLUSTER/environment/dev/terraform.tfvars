project_name                       = "linuxtips-ecs-cluster"
region                             = "eu-central-1"
vpc_id                             = "/linuxtips-aca/vpc/vpc-id"
private_subnet_1a                  = "/linuxtips-aca/vpc/private-subnet-1a"
private_subnet_1b                  = "/linuxtips-aca/vpc/private-subnet-1b"
private_subnet_1c                  = "/linuxtips-aca/vpc/private-subnet-1c"
public_subnet_1a                   = "/linuxtips-aca/vpc/public-subnet-1a"
public_subnet_1b                   = "/linuxtips-aca/vpc/public-subnet-1b"
public_subnet_1c                   = "/linuxtips-aca/vpc/public-subnet-1c"
database_subnet_1a                 = "/linuxtips-aca/vpc/database-subnet-1a"
database_subnet_1b                 = "/linuxtips-aca/vpc/database-subnet-1b"
database_subnet_1c                 = "/linuxtips-aca/vpc/database-subnet-1c"
loadbalancer_internal              = false
loadbalancer_type                  = "application"
node_ami                           = "ami-087925fac10d4c4f1"
node_instance_type                 = "t3a.large"
node_volume_size                   = 30
node_volume_type                   = "gp3"
cluster_on_demand_desired_capacity = 3
cluster_on_demand_max_size         = 4
cluster_on_demand_min_size         = 1
cluster_spots_desired_capacity     = 3
cluster_spots_max_size             = 4
cluster_spots_min_size             = 1