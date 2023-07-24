##Description : This Script is used to create VPC.
#Module      : LABEL
#Description : Terraform label module variables.
module "labels" {
  source      = "terraform-do-modules/labels/digitalocean"
  version     = "0.0.1"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

#################################################################################################
##Description : Uptime Checks provide the ability to monitor your endpoints from around the world
#################################################################################################
resource "digitalocean_uptime_check" "main" {
  count   = var.enabled && var.uptime_alerts ? 1 : 0
  name    = format("%s-uptime-check", module.labels.id)
  target  = var.target_url
  type    = var.type
  regions = var.regions
  enabled = var.enable
}

################################################################################################################################################################################
##Description : Uptime Alerts provide the ability to add alerts to your DigitalOcean Uptime Checks when your endpoints are slow, unavailable, or SSL certificates are expiring.
################################################################################################################################################################################
resource "digitalocean_uptime_alert" "main" {
  count      = var.enabled && var.uptime_alerts ? 1 : 0
  name       = format("%s-alert", module.labels.id)
  check_id   = join("", digitalocean_uptime_check.main[*].id)
  type       = var.alert_type
  threshold  = var.threshold
  comparison = var.comparison
  period     = var.period

  dynamic "notifications" {
    for_each = try(jsondecode(var.notifications), var.notifications) ##var.notifications == [] ? 0 : 1
    content {
      email = lookup(notifications.value, "email", null)
      dynamic "slack" {
        for_each = lookup(notifications.value, "slack", [])
        content {
          channel = lookup(slack.value, "channel", null)
          url     = lookup(slack.value, "url", null)
        }
      }
    }
  }
}

###########################################################
##Description :Monitor alerts can be configured to alert
###########################################################
resource "digitalocean_monitor_alert" "cpu_alert" {
  for_each = var.resource_alerts
  dynamic "alerts" {
    for_each = each.value.alerts
    content {
      email = lookup(alerts.value, "email", null)
      dynamic "slack" {
        for_each = lookup(alerts.value, "slack", null)
        content {
          channel = lookup(slack.value, "channel", null)
          url     = lookup(slack.value, "url", null)
        }
      }
    }
  }
  description = lookup(each.value, "description", null)
  compare     = lookup(each.value, "compare", null)
  type        = lookup(each.value, "type", null)
  enabled     = lookup(each.value, "enabled", true)
  entities    = lookup(each.value, "entities", null)
  value       = lookup(each.value, "value", 95)
  window      = lookup(each.value, "window", "5m")
  tags        = lookup(each.value, "tags", null)
}
