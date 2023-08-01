##Description : This Script is used to create VPC.
#Module      : LABEL
#Description : Terraform label module variables.
module "labels" {
  source      = "terraform-do-modules/labels/digitalocean"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

#################################################################################################
##Description : Uptime Checks provide the ability to monitor your endpoints from around the world
#################################################################################################
resource "digitalocean_uptime_check" "main" {
  count   = var.enable ? length(var.target_url) : 0
  name    = format("%s-uptime-check-%s", module.labels.id, count.index)
  target  = element(var.target_url, count.index)
  type    = element(var.type, count.index)
  regions = var.regions
  enabled = var.enabled
}

################################################################################################################################################################################
##Description : Uptime Alerts provide the ability to add alerts to your DigitalOcean Uptime Checks when your endpoints are slow, unavailable, or SSL certificates are expiring.
################################################################################################################################################################################
resource "digitalocean_uptime_alert" "main" {
  count      = var.enable ? length(var.target_url) : 0
  name       = format("%s-alert", module.labels.id)
  check_id   = element(concat(digitalocean_uptime_check.main[*].id, [""]), count.index)
  type       = element(var.alert_type, count.index)
  threshold  = element(var.threshold, count.index)
  comparison = element(var.comparison, count.index)
  period     = element(var.period, count.index)

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
