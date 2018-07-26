# #############################################################################
# Output Variables (stored in tfstate)
#

output "client_key" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate}"
}

output "cluster_name" {
  value = "${local.cluster_fullname}"
}

output "cluster_username" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
}

output "cluster_password" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
}

output "container_registry_login_server" {
  value = "${azurerm_container_registry.k8s.login_server}"
}

output "container_registry_name" {
  value = "${local.container_registry_fullname}"
}

output "container_registry_password" {
  value = "${azurerm_container_registry.k8s.admin_password}"
}

output "container_registry_username" {
  value = "${azurerm_container_registry.k8s.admin_username}"
}

output "dashboard_command" {
  value = "az aks browse --resource-group ${local.resource_group_fullname} --name ${local.cluster_fullname}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "resource_group_name" {
  value = "${local.resource_group_fullname}"
}

# #############################################################################

