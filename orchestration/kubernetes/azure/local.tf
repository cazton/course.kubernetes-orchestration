locals {
  cluster_fullname            = "${var.cluster["name"]}-${var.env}"
  container_registry_fullname = "${var.container_registry["name"]}${replace(var.env, "/[[:^alnum:]]/", "")}"
  resource_group_fullname     = "${var.resource_group["name"]}-${var.env}"
}
