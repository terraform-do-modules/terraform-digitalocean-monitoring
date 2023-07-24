provider "digitalocean" {}

locals {
  name        = "app"
  environment = "test"
  region      = "blr1"
}

##------------------------------------------------
## VPC module call
##------------------------------------------------
module "vpc" {
  source      = "git::https://github.com/terraform-do-modules/terraform-digitalocean-vpc.git?ref=internal-423"
  name        = local.name
  environment = local.environment
  region      = local.region
  ip_range    = "10.10.0.0/16"
}

##------------------------------------------------
## Droplet module call
##------------------------------------------------
module "droplet" {
  source      = "git::https://github.com/terraform-do-modules/terraform-digitalocean-droplet.git?ref=internal-425"
  name        = local.name
  environment = local.environment
  region      = local.region
  vpc_uuid    = module.vpc.id

  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABg"
  ####firewall
  inbound_rules = [
    {
      allowed_ip    = ["10.10.0.0/16"]
      allowed_ports = "22"
    },
    {
      allowed_ip    = ["0.0.0.0/0"]
      allowed_ports = "80"
    }
  ]
}

##------------------------------------------------
## resource alert module call.
##------------------------------------------------
module "resource-alert" {
  source      = "./../.."
  name        = local.name
  environment = local.environment
  resource_alerts = {
    "alert1" = {
      alerts = [
        {
          email = ["example@gmail.com"]
          slack = [{
            channel = "testing"
            url     = "https://hooks.slack.com/services/TEXXXXXXXXxxxxYTGH8DNkjgggyKipj"
          }]
        }
      ]
      window      = "5m"
      type        = "v1/insights/droplet/cpu"
      compare     = "GreaterThan"
      value       = 95
      enabled     = true
      entities    = [module.droplet.id[0]]
      description = "Alert about CPU usage"
      tags        = ["test"]
    },
  }
}
