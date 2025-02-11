resource "azurerm_kubernetes_cluster" "pc" {
  name                = "${local.prefix}-cluster"
  location            = azurerm_resource_group.pc.location
  resource_group_name = azurerm_resource_group.pc.name
  dns_prefix          = "${local.prefix}-cluster"
  kubernetes_version  = var.k8s_version

  addon_profile {
    kube_dashboard {
      enabled = false
    }
  }

  default_node_pool {
    name           = "agentpool"
    vm_size        = "Standard_DS2_v2"
    node_count     = var.aks_node_count
    vnet_subnet_id = azurerm_subnet.node_subnet.id
    orchestrator_version = var.k8s_version
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      azure_rbac_enabled = true
    }

  }
  # TODO(azurerm 3.x)
  # azure_active_directory_role_based_access_control {
  #   managed = true
  #   azure_rbac_enabled = true
  # }

  tags = {
    Environment = var.environment
    ManagedBy   = "AI4E"
  }
}

# add the role to the identity the kubernetes cluster was assigned
resource "azurerm_role_assignment" "network" {
  scope                = azurerm_resource_group.pc.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.pc.identity[0].principal_id
}
