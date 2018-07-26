# #############################################################################
# Subnet Setting for AZ-A
#

resource "aws_subnet" "subnet-main-prv" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["subnet-main-prv"]}"
  availability_zone = "${var.availability-zones["main"]}"

  tags = "${
    map(
     "Name", "${var.env}-rt-main-prv",
     "Environment", "${var.env}",
     "kubernetes.io/cluster/${local.cluster_fullname}", "shared"
  )}"
}

# route table association
resource "aws_route_table" "rt-main-prv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name        = "${var.env}-rt-main-prv"
    Environment = "${var.env}"
  }
}

# route table association Zone-A
resource "aws_route_table_association" "rt-main-prv" {
  subnet_id      = "${aws_subnet.subnet-main-prv.id}"
  route_table_id = "${aws_route_table.rt-main-prv.id}"
}

# #############################################################################
# Subnet Setting for AZ-C
#

resource "aws_subnet" "subnet-nodes-prv" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["subnet-nodes-prv"]}"
  availability_zone = "${var.availability-zones["nodes"]}"

  tags = "${
    map(
     "Name", "${var.env}-rt-nodes-prv",
     "Environment", "${var.env}",
     "kubernetes.io/cluster/${local.cluster_fullname}", "shared"
  )}"
}

# route table association
resource "aws_route_table" "subnet-nodes-prv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name        = "${var.env}-rt-nodes-prv"
    Environment = "${var.env}"
  }
}

# route table association Zone-C
resource "aws_route_table_association" "subnet-nodes-prv" {
  subnet_id      = "${aws_subnet.subnet-nodes-prv.id}"
  route_table_id = "${aws_route_table.subnet-nodes-prv.id}"
}

# #############################################################################

