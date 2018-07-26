# #############################################################################
# Container Registry (docker)
#

resource "azurerm_container_registry" "k8s" {
  name                = "${local.container_registry_fullname}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  location            = "${azurerm_resource_group.k8s.location}"
  admin_enabled       = true
  sku                 = "Basic"

  tags = "${
    map(
     "Environment", "${var.env}",
  )}"
}

resource "kubernetes_secret" "k8s" {
  metadata {
    name = "docker-registry"
  }

  data {
    docker-password = "${azurerm_container_registry.k8s.admin_password}"
    docker-server   = "${azurerm_container_registry.k8s.login_server}"
    docker-username = "${azurerm_container_registry.k8s.admin_username}"
  }
}

# #############################################################################

