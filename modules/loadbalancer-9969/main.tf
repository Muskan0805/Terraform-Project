# NOTE: the brief says "basic" load balancer, but Microsoft retired the Basic
# SKU (and Basic public IPs) on 30 Sept 2025 - Azure now refuses to create
# them. Standard is the only option, so that's what this uses.

resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.humber_id}-LB-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"] # zone-redundant, like the VMs behind it
  domain_name_label   = "lb${var.humber_id}-ccgc5502"
  tags                = var.tags
}

resource "azurerm_lb" "lb" {
  name                = "${var.humber_id}-LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "${var.humber_id}-LB-frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  name            = "${var.humber_id}-LB-backend"
  loadbalancer_id = azurerm_lb.lb.id
}

# Puts each Linux VM's NIC into the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "assoc" {
  for_each                = var.linux_nic_ids
  network_interface_id    = each.value
  ip_configuration_name   = var.ip_config_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

# The LB only sends traffic to VMs that answer this check
resource "azurerm_lb_probe" "probe" {
  name            = "${var.humber_id}-LB-probe-80"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "http" {
  name                           = "${var.humber_id}-LB-rule-http"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  # VMs already reach the internet through their own public IPs
  disable_outbound_snat = true
}
