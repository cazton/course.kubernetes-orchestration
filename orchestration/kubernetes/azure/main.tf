# #############################################################################
# Main Settings
#

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"
}

provider "kubernetes" {}

# terraform {
#   description = "Set this value to save tfstate in backend provider"
#   backend     = "azurerm"
# }

