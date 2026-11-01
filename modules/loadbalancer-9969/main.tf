# Standard SKU: Microsoft retired the Basic load balancer on 30 Sept 2025.

resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.humber_id}-LB-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.lb_sku
  zones               = var.frontend_zones
  domain_name_label   = "lb${var.humber_id}-ccgc5502"
  tags                = var.tags
}

resource "azurerm_lb" "lb" {
  name                = "${var.humber_id}-LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.lb_sku
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

resource "azurerm_network_interface_backend_address_pool_association" "assoc" {
  for_each                = var.linux_nic_ids
  network_interface_id    = each.value
  ip_configuration_name   = var.ip_config_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

resource "azurerm_lb_probe" "probe" {
  name            = "${var.humber_id}-LB-probe-${var.probe_port}"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = var.probe_protocol
  port            = var.probe_port
}

resource "azurerm_lb_rule" "http" {
  name                           = "${var.humber_id}-LB-rule-http"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = var.rule_protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  disable_outbound_snat          = var.disable_outbound_snat
}
