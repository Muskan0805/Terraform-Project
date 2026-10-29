# A null_resource doesn't create anything in Azure. It exists only to run the
# remote-exec provisioner: SSH into each VM and print its hostname.
# One per VM (same for_each), so you see all 3 hostnames in the apply log.
resource "null_resource" "show_hostname" {
  for_each = var.linux_vms

  # waits for the extensions so the SSH session doesn't race their installs
  depends_on = [azurerm_virtual_machine_extension.azure_monitor]

  # if a VM gets replaced, re-run for that VM
  triggers = {
    vm_id = azurerm_linux_virtual_machine.vm[each.key].id
  }

  connection {
    type        = "ssh"
    user        = var.admin_username
    private_key = file(var.private_key_path)
    host        = azurerm_public_ip.pip[each.key].fqdn
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = ["echo \"Hostname: $(hostname)\""]
  }
}
