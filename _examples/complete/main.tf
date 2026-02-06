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
  source      = "terraform-do-modules/vpc/digitalocean"
  version     = "1.0.1"
  name        = local.name
  environment = local.environment
  region      = local.region
  ip_range    = "10.10.0.0/16"
}

##------------------------------------------------
## Droplet module call
##------------------------------------------------
module "droplet" {
  source      = "terraform-do-modules/droplet/digitalocean"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  region      = local.region
  vpc_uuid    = module.vpc.id
  ssh_keys = {
    key1 = {
      name       = "my-ssh-key"
      public_key = "ssh-rsa AAAAB3NzaC1yc2E"
    }
  }

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
## Uptime alert module call
##------------------------------------------------
module "uptime-alert" {
  source      = "./../.."
  name        = local.name
  environment = local.environment
  target_url  = ["http://test.do.clouddrove.ca/"]
  type        = ["http"]
  alert_type  = ["down_global"]
  period      = ["2m"]
  comparison  = ["less_than"]

  notifications = [
    {
      email = ["example@gmail.com"]
      slack = [
        {
          channel = "testing"
          url     = "https://hooks.slack.com/services/TEXXXXXXXXxxxxYTGH8DNkjgggyKipj"
        }
      ]
    }
  ]
}

##------------------------------------------------
## Resource alert module call
##------------------------------------------------
module "resource-alert" {
  source      = "./../.."
  name        = "${local.name}-resource"
  environment = local.environment

  resource_alerts = {
    "cpu-alert" = {
      alerts = [
        {
          email = ["example@gmail.com"]
          slack = [
            {
              channel = "testing"
              url     = "https://hooks.slack.com/services/TEXXXXXXXXxxxxYTGH8DNkjgggyKipj"
            }
          ]
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
