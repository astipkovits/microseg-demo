locals {
  env_name   = "mseg-tst"
  ha_enabled = false
}

#Create Azure Transit
module "azure_transit_1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.2.0"

  cloud                         = "Azure"
  name                          = "${local.env_name}-tr1"
  cidr                          = "10.100.0.0/23"
  instance_size                 = "Standard_B1ms"
  region                        = var.azure_region
  account                       = var.controller_azure_acct
  ha_gw                         = local.ha_enabled
}

#Create Azure Spoke1
module "spoke_azure_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.0"

  cloud         = "Azure"
  name          = "${local.env_name}-spk1"
  cidr          = "10.3.0.0/24"
  region        = var.azure_region
  account       = var.controller_azure_acct
  transit_gw    = module.azure_transit_1.transit_gateway.gw_name
  ha_gw         = local.ha_enabled
  instance_size = "Standard_B1ms"
}

#Create Azure Spoke2
module "spoke_azure_2" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.0"

  cloud         = "Azure"
  name          = "${local.env_name}-spk2"
  cidr          = "10.2.0.0/24"
  region        = var.azure_region
  account       = var.controller_azure_acct
  transit_gw    = module.azure_transit_1.transit_gateway.gw_name
  ha_gw         = local.ha_enabled
  instance_size = "Standard_B1ms"
}


#Create Test VM in Spoke1 VNET
module "azure_linux1" {
  source = "github.com/astipkovits/terraform-azure-ubuntu"

  name           = "${local.env_name}-testvm1"
  admin_username = var.linux_user
  admin_password = var.linux_pass
  resource_group = split("/", module.spoke_azure_1.vpc.azure_vnet_resource_id)[4]
  size           = "Standard_B1ls"
  region         = var.azure_region
  subnet_id      = module.spoke_azure_1.vpc.public_subnets[1].subnet_id
  tags = {
    app = "business-app1"
  }

  command = "apt-get update && apt-get install -y apache2"
}

#Create Test VM in Spoke2 VNET
module "azure_linux2" {
  source = "github.com/astipkovits/terraform-azure-ubuntu"

  name           = "${local.env_name}-testvm2"
  admin_username = var.linux_user
  admin_password = var.linux_pass
  resource_group = split("/", module.spoke_azure_2.vpc.azure_vnet_resource_id)[4]
  size           = "Standard_B1ls"
  region         = var.azure_region
  subnet_id      = module.spoke_azure_2.vpc.public_subnets[1].subnet_id
  tags = {
    app = "business-app2"
  }

  command = "apt-get update && apt-get install -y apache2"
}

#Create Test VM2 in Spoke2 VNET
module "azure_linux3" {
  source = "github.com/astipkovits/terraform-azure-ubuntu"

  name           = "${local.env_name}-testvm3"
  admin_username = var.linux_user
  admin_password = var.linux_pass
  resource_group = split("/", module.spoke_azure_2.vpc.azure_vnet_resource_id)[4]
  size           = "Standard_B1ls"
  region         = var.azure_region
  subnet_id      = module.spoke_azure_2.vpc.public_subnets[1].subnet_id
  tags = {
    app = "business-app1"
  }

  command = "apt-get update && apt-get install -y apache2"
}

#Microseg definition
resource "aviatrix_app_domain" "business_app1" {
  name = "business-app1"
  selector {
    match_expressions {
      type         = "vm"
      tags         = {
        app = "business-app1"
      }
    }
  }
}

resource "aviatrix_app_domain" "business_app2" {
  name = "business-app2"
  selector {
    match_expressions {
      type         = "vm"
      tags         = {
        app = "business-app2"
      }
    }
  }
}

resource "aviatrix_app_domain" "catch_all" {
  name = "catch-all"
  selector {
    match_expressions {
      cidr = "0.0.0.0/0"
    }
  }
}

#Microseg policy - allows icmp, denys anything else
resource "aviatrix_microseg_policy_list" "policies" {

  #Need a policy to enable communication within a domain as well!
  policies {
    name            = "allow-app1-intradomain"
    action          = "PERMIT"
    priority        = 1
    protocol        = "ANY"
    logging         = false
    watch           = false
    src_app_domains = [
      aviatrix_app_domain.business_app1.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.business_app1.uuid
    ]
  }

  #Need a policy to enable communication within a domain as well!
  policies {
    name            = "allow-app2-intradomain"
    action          = "PERMIT"
    priority        = 2
    protocol        = "ANY"
    logging         = false
    watch           = false
    src_app_domains = [
      aviatrix_app_domain.business_app2.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.business_app2.uuid
    ]
  }

  #Cross domain communication (rules are bidirectional)
  policies {
    name            = "app1-app2"
    action          = "PERMIT"
    priority        = 3
    protocol        = "ICMP"
    logging         = false
    watch           = false
    src_app_domains = [
      aviatrix_app_domain.business_app1.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.business_app2.uuid
    ]
  }
  
  
  policies {
    name            = "drop-all"
    action          = "DENY"
    priority        = 1000
    protocol        = "ANY"
    src_app_domains = [
      aviatrix_app_domain.catch_all.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.catch_all.uuid
    ]
  }
}


