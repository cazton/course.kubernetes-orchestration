# #############################################################################
# Cluster Configuration
#

resource "aws_security_group" "eks-cluster" {
  name        = "${local.cluster_fullname}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.cluster_fullname}-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-nodes.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-laptop-https" {
  cidr_blocks       = ["${var.external-ip}"]
  description       = "Allow laptop to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${local.cluster_fullname}"
  role_arn = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]

    subnet_ids = [
      "${aws_subnet.subnet-main-prv.*.id}",
      "${aws_subnet.subnet-nodes-prv.*.id}",
    ]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSServicePolicy",
  ]
}

resource "aws_iam_role" "eks-cluster" {
  name               = "${local.cluster_fullname}"
  path               = "/"
  assume_role_policy = "${file("./json/cluster-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

# #############################################################################

