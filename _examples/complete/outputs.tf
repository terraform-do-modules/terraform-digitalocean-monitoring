output "uptime_check_id" {
  value       = module.uptime-alert.uptime_check_id
  description = "ID of uptime check"
}

output "uptime_alert_id" {
  value       = module.uptime-alert.uptime_alert_id
  description = "ID of uptime alert"
}

output "resource_alert_id" {
  value       = module.resource-alert.resource_alert_id
  description = "ID of resource alert"
}
