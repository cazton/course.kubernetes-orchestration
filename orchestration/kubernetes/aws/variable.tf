# #############################################################################
# Variables
#

variable "region" {
  default     = "us-east-1"
  description = "Region"
}

# You may need to change this list when AWS returns
# an UnsupportedAvailabilityZoneException
variable "availability-zones" {
  type = "map"

  default = {
    main  = "us-east-1a"
    nodes = "us-east-1b"
  }
}

variable "vpc" {
  type = "map"

  default = {
    main             = "10.0.0.0/16"
    subnet-main-prv  = "10.0.32.0/20"
    subnet-nodes-prv = "10.0.96.0/20"
  }
}

variable "env" {
  description = "The cluster environment (e.g. development, integration, production)"
  default     = "development"
}

variable "external-ip" {
  default = "5.194.139.128/32"
}

variable "nodes_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    name                 = "eks-nodes"    # Name for the eks workers.
    ami_id               = "ami-dea4d5a1" # AMI ID for the eks workers. If none is provided, Terraform will searchfor the latest version of their EKS optimized worker AMI.
    asg_desired_capacity = "2"            # Desired worker capacity in the autoscaling group.
    asg_max_size         = "2"            # Maximum worker capacity in the autoscaling group.
    asg_min_size         = "2"            # Minimum worker capacity in the autoscaling group.
    instance_type        = "t2.small"     # Size of the workers instances.
    key_name             = "eks-key"      # The key name that should be used for the instances in the autoscaling group.
    ebs_optimized        = false          # Sets whether to use ebs optimization on supported types.
    public_ip            = false          # Associate a public ip address with a worker.
  }
}

variable "cluster_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    name = "eks-cluster" # Name for the eks cluster.
  }
}
