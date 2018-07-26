# #############################################################################
# Virtual Private Cloud
#

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc["main"]}"

  tags = "${
    map(
     "Name", "${var.env}-vpc",
     "Environment", "${var.env}",
     "kubernetes.io/cluster/${local.cluster_fullname}", "shared"
  )}"
}

# #############################################################################
# AWS Provider with Credentials
#

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = "${var.region}"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local laptop external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See laptop-external-ip.tf for additional information.
provider "http" {}

# #############################################################################
# Internet Gateway
#

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.env}-igw"
    Environment = "${var.env}"
  }
}

# keypair for ec2
resource "aws_key_pair" "eks-prod-key" {
  key_name   = "${var.nodes_defaults["key_name"]}"
  public_key = "${file("./.aws/admin_node_rsa.pub")}"
}

# #############################################################################

