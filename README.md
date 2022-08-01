# Aviatrix Microsegmentation Demo
Terraform code for deploying Aviatrix microsegmantation demo environment.
The resulting topology is a transit in Azure with two spokes and three VMs. 

The VMs belong to the following applications based on CSP tags applied:  
Business App 1: VM1, VM3  
Business App 2 VM2

The policy applied allows communication within each application domain freely, but only allows ping between application 1 and application 2. All VMs have apache server installed however curl will only work withn the application domains, but not between them.

# Variables
The follwing variables are used
|**key** |**value**  | **required** |
|--|--| -- |
|azure_region  |Azure region to use  | yes
|controller_ip  |Aviatrix controller IP or hostname   | yes
|controller_user  |Aviatrix controller username  | yes
|controller_pass  |Aviatrix controller password | yes
|controller_azure_acct  |The name of the Azure account on the Aviatrix controller  | yes
|azure_subscription_id  |Azure subscription ID for the VMs  | yes
|azure_client_id  |Azure client ID  | yes
|azure_client_secret  |Azure client secret  | yes
|azure_tenant_id  |Azure tenant ID  | yes
|linux_user |The userrname of the deplyoed linux VMs  | yes
|linux_pass  |The password for the deployed linux VMs  | yes
# Outputs
|**key** |**value**  |
|--|--|
|azure_vm1_mgmt_ip  |Azure VM1 management IP  
|azure_vm1_private_ip  |Azure VM1 private IP
|azure_vm2_mgmt_ip  |Azure VM2 management IP  
|azure_vm2_private_ip  |Azure VM2 private IP 
|azure_vm3_mgmt_ip  |Azure VM3 management IP  
|azure_vm3_private_ip  |Azure VM3 private IP 
