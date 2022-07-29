
output "azure_vm1_mgmt_ip" {
  value = module.azure_linux1.linux_mgmt_ip
}

output "azure_vm1_private_ip" {
  value = "${module.azure_linux1.linux_private_ip}"
}


output "azure_vm2_mgmt_ip" {
  value = module.azure_linux2.linux_mgmt_ip
}

output "azure_vm2_private_ip" {
  value = "${module.azure_linux2.linux_private_ip}"
}

output "azure_vm3_mgmt_ip" {
  value = module.azure_linux3.linux_mgmt_ip
}

output "azure_vm3_private_ip" {
  value = "${module.azure_linux3.linux_private_ip}"
}