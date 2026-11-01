# null_resource creates nothing in Azure; it exists to run remote-exec,
# which SSHes into each VM and prints its hostname.
resource "null_resource" "show_hostname" {
  for_each = var.linux_vms

  depends_on = [azurerm_virtual_machine_extension.azure_monitor]

  triggers = {
    vm_id = azurerm_linux_virtual_machine.vm[each.key].id
  }

  connection {
    type        = "ssh"
    user        = var.admin_username
    private_key = file(var.private_key_path)
    host        = azurerm_public_ip.pip[each.key].fqdn
    timeout     = var.ssh_timeout
  }

  provisioner "remote-exec" {
    inline = ["echo \"Hostname: $(hostname)\""]
  }
}
