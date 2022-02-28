
data "azurerm_resource_group" "network" {
  name = "rg-${var.environment_prefix}-${var.azure_resource_group_postfix}"
}

module "vd_network" {
  source = "../../terraform-modules/azurerm/network"
  tags = merge(
    {
      "environment" = var.environment_prefix
    },
    var.azure_tags
  )
  location            = data.azurerm_resource_group.network.location
  resource_group_name = data.azurerm_resource_group.network.name
  route_table_name    = "rtb-${var.environment_prefix}"
  # route_table_disable_bgp_route_propagation = var.azure_route_table_disable_bgp_route_propagation
  virtual_network_name                                                  = "vnet-${var.environment_prefix}"
  virtual_network_subnet_names                                          = var.azure_virtual_network_subnet_names
  virtual_network_subnet_enforce_private_link_endpoint_network_policies = true
  virtual_network_subnet_service_endpoints                              = ["Microsoft.Storage"]
  virtual_network_dns_servers                                           = var.azure_virtual_network_dns_servers
  virtual_network_address_space                                         = var.azure_virtual_network_address_space
  virtual_network_subnet_address_prefixes                               = var.azure_virual_network_subnet_address_prefixes
  // route_table_routes                = [
  //   {
  //     name = "rtb-${var.environment_prefix}-vpn-onprem",
  //     address_prefix = "192.168.120.0/24",
  //     next_hop_type = "VirtualNetworkGateway",
  //     next_hop_in_ip_address = null
  //   },
  //   {
  //     name = "rtb-${var.environment_prefix}-vpn-somewhere",
  //     address_prefix = "192.168.234.0/24",
  //     next_hop_type = "VirtualAppliance",
  //     next_hop_in_ip_address = cidrhost(azurerm_subnet.wg[0].address_prefixes[0], var.wg_private_ip_address_start)
  //   }
  // ]
}

resource "local_file" "ansible_vars" {
  content  = <<-DOC
    ---
    # Generated by terraform
    # Ansible vars_file containing variable for
    # initiating and applying virtual_network_dns_servers
    azure_bootstrap_resource_group_name: '${var.azure_bootstrap_resource_group_name}'
    azure_bootstrap_storage_account_name: '${var.azure_bootstrap_storage_account_name}'
    azure_bootstrap_storage_account_container_name: '${var.azure_bootstrap_storage_account_container_name}'
    terraform_project_path: '../terraform/${basename(path.cwd)}'
    terraform_project_name: '${basename(path.cwd)}'
    terraform_tfstate_file_name: '${basename(path.cwd)}.tfstate'
    terraform_variables_files: ["../../global.tfvars"]
    DOC
  filename = "${replace(dirname(path.cwd), "terraform", "ansible")}/vars/${var.generated_for_ansible_file_prefix}${basename(path.cwd)}.yml"

  depends_on = [module.vd_network]
}

output "network_vnet_id" {
  value = module.vd_network.network_vnet_id
}
output "network_vnet_name" {
  value = module.vd_network.network_vnet_name
}
output "network_vnet_location" {
  value = module.vd_network.network_vnet_location
}
output "network_vnet_address_space" {
  value = module.vd_network.network_vnet_address_space
}
output "network_vnet_subnets" {
  value = module.vd_network.network_vnet_subnets
}
output "network_route_table_id" {
  value = module.vd_network.network_route_table_id
}
output "network_route_table_name" {
  value = module.vd_network.network_route_table_name
}