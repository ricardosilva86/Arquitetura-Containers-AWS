variable "project_name" {
  description = "The name of the project"
}
variable "region" {
  description = "The region to deploy the resources"
}

### SSM Parameter Variables
variable "vpc_id" {
  description = "SSM Parameter to store the ID of the VPC"
}
variable "private_subnet_1a" {
  description = "SSM Parameter to store the ID of the private subnet in the first availability zone"
}
variable "private_subnet_1b" {
  description = "SSM Parameter to store the ID of the private subnet in the second availability zone"
}
variable "private_subnet_1c" {
  description = "SSM Parameter to store the ID of the private subnet in the third availability zone"
}
variable "public_subnet_1a" {
  description = "SSM Parameter to store the ID of the public subnet in the first availability zone"
}
variable "public_subnet_1b" {
  description = "SSM Parameter to store the ID of the public subnet in the second availability zone"
}
variable "public_subnet_1c" {
  description = "SSM Parameter to store the ID of the public subnet in the third availability zone"
}
variable "database_subnet_1a" {
  description = "SSM Parameter to store the ID of the database subnet in the first availability zone"
}
variable "database_subnet_1b" {
  description = "SSM Parameter to store the ID of the database subnet in the second availability zone"
}
variable "database_subnet_1c" {
  description = "SSM Parameter to store the ID of the database subnet in the third availability zone"
}

### LoadBalancer Variables
variable "loadbalancer_internal" {
  description = "Whether the load balancer is internal or not"
}
variable "loadbalancer_type" {
  description = "The type of the load balancer, i.e. 'application' or 'network'"
}

### ECS Node Variables
variable "node_ami" {
  description = "The AMI to use for the ECS cluster instances"
}
variable "node_instance_type" {
  description = "The instance type to use for the ECS cluster instances"
}
variable "node_volume_size" {
  description = "The size of the volume to use for the ECS cluster instances"
}
variable "node_volume_type" {
  description = "The type of the volume to use for the ECS cluster instances"
}

### ECS Cluster Variables
variable "cluster_on_demand_max_size" {
  description = "The maximum size of the on-demand instances in the ECS cluster"
}

variable "cluster_on_demand_min_size" {
  description = "The minimum size of the on-demand instances in the ECS cluster"
}

variable "cluster_on_demand_desired_capacity" {
  description = "The desired capacity of the on-demand instances in the ECS cluster"
}

variable "cluster_spots_max_size" {
  description = "The maximum size of the Spot instances in the ECS cluster"
}

variable "cluster_spots_min_size" {
  description = "The minimum size of the Spot instances in the ECS cluster"
}

variable "cluster_spots_desired_capacity" {
  description = "The desired capacity of the Spot instances in the ECS cluster"
}
