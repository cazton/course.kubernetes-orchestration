# #############################################################################
# AKS Cluster
#

resource "azurerm_resource_group" "k8s" {
  name     = "${local.resource_group_fullname}"
  location = "${var.resource_group["location"]}"

  tags = "${
    map(
     "Environment", "${var.env}",
  )}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${local.cluster_fullname}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  dns_prefix          = "${var.cluster["dns_prefix"]}"
  kubernetes_version  = "${var.cluster["kubernetes_version"]}"

  linux_profile {
    admin_username = "${var.node_pool["admin_username"]}"

    ssh_key {
      key_data = "${file("${var.node_pool["ssh_public_key"]}")}"
    }
  }

  agent_pool_profile {
    name            = "${var.node_pool["name"]}"
    count           = "${var.node_pool["agent_count"]}"
    vm_size         = "${var.node_pool["vm_size"]}"
    os_type         = "${var.node_pool["os_type"]}"
    os_disk_size_gb = "${var.node_pool["os_disk_size_gb"]}"
  }

  service_principal {
    client_id     = "${var.service_principal_client_id}"
    client_secret = "${var.service_principal_client_secret}"
  }

  tags = "${
    map(
     "Name", "${var.cluster["name"]}",
     "Environment", "${var.env}",
  )}"
}

# #############################################################################

