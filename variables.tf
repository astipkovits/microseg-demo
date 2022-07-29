variable "azure_region" {
  type    = string
  default = "West Europe"
}

variable "controller_ip" {
  type = string
}

variable "controller_user" {
  type = string
}

variable "controller_pass" {
  type      = string
  sensitive = true
}

variable "controller_azure_acct" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}

variable "azure_tenant_id" {
  type = string
}

variable "linux_user" {
  type    = string
  default = "ubuntu"
}

variable "linux_pass" {
  type      = string
  sensitive = true
}



