# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "uptime_check_id" {
  value       = element(concat(digitalocean_uptime_check.main[*].id[*], [""]), 0) ##digitalocean_uptime_check.main[*].id[*]
  description = " The id of the check."
}
output "uptime_alert_id" {
  value       = join("", digitalocean_uptime_alert.main[*].id)
  description = "The id of the alert."
}

output "uuid" {
  value       = digitalocean_monitor_alert.cpu_alert
  description = "The uuid of the alert."
}
