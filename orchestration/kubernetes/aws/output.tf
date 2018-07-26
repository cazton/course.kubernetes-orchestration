# #############################################################################
# Output Template for Kubectl Configuration
#
output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "cluster_name" {
  description = "The name/id of the EKS cluster."
  value       = "${aws_eks_cluster.eks-cluster.id}"
}

output "cluster_ca_certificate" {
  value = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
}

output "host" {
  value = "${aws_eks_cluster.eks-cluster.endpoint}"
}

# #############################################################################

