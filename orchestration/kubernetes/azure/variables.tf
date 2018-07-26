# #############################################################################
# Variables
#

variable "cluster" {
  description = "Cluster settings"
  type        = "map"

  default = {
    dns_prefix         = "k8s"         # The dns prefix 
    kubernetes_version = "1.10.5"
    name               = "aks-cluster" # The name for your cluster
  }
}

variable "container_registry" {
  description = "Docker container registry settings"
  type        = "map"

  default = {
    name = "christophertown" # The unique name
  }
}

variable "env" {
  description = "The cluster environment (e.g. development, integration, production)"
  default     = "development"
}

variable "node_pool" {
  description = "Agent node pool settings"
  type        = "map"

  default = {
    admin_username  = "ubuntu"                    # The cluster admin 
    agent_count     = 2                           # The default number of nodes to create
    name            = "default"                   # The pool name
    os_disk_size_gb = 30                          # The node disk size in GB
    os_type         = "Linux"                     # The OS type
    ssh_public_key  = ".azure/admin_node_rsa.pub" # The admin ssh key for pool VMs
    vm_size         = "Standard_D2"               # The VM size
  }
}

variable "resource_group" {
  description = "Resource group settings"
  type        = "map"

  default = {
    name     = "k8s"     # The resource group name
    location = "East US" # The resource group location
  }
}

variable "subscription_id" {
  description = "Azure subscription id"
}

variable "tenant_id" {
  description = "Azure tenant id"
}

variable "service_principal_client_id" {
  description = "Service account client id"
}

variable "service_principal_client_secret" {
  description = "Service account client secret"
}

# #############################################################################

