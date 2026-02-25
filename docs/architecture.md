# terraform-digitalocean-monitoring — Architecture

## Overview

This module provisions two categories of DigitalOcean monitoring resources:

1. **Uptime checks and alerts** — endpoint health monitoring from globally distributed probe locations.
2. **Resource alerts** — threshold-based alerts on Droplet and infrastructure metrics (CPU, memory, disk, bandwidth).

Both types support email and Slack notification channels.

---

## Uptime Checks

Uptime checks are created via the `digitalocean_uptime_check` resource. Each check monitors a single endpoint URL. The module accepts a list of URLs and creates one check per entry.

### Check Types

The `type` variable controls the protocol used for health checks:

| Value   | Description                                |
|---------|--------------------------------------------|
| `ping`  | ICMP ping to the target host               |
| `http`  | HTTP request (port 80)                     |
| `https` | HTTPS request with TLS validation (port 443) |

### Probe Regions

The `regions` variable specifies which DigitalOcean probe regions perform the checks. Accepted values:

| Value      | Location          |
|------------|-------------------|
| `us_east`  | United States East |
| `us_west`  | United States West |
| `eu_west`  | Europe West        |
| `se_asia`  | Southeast Asia     |

The default is all four regions. Checks from multiple regions provide global coverage and reduce false positives from regional outages.

---

## Uptime Alerts

Each uptime check has a corresponding `digitalocean_uptime_alert` resource. Alerts fire when the check crosses the configured threshold for the specified period.

### Alert Types

The `alert_type` variable must be one of:

| Value        | Description                                        |
|--------------|----------------------------------------------------|
| `down`       | Alert when the endpoint is down from any region    |
| `down_global`| Alert when the endpoint is down from all regions   |
| `latency`    | Alert when response latency exceeds the threshold  |
| `ssl_expiry` | Alert when the TLS certificate will expire soon    |

### Period

The `period` variable sets how long the threshold must be exceeded before the alert fires. Valid values: `2m`, `3m`, `5m`, `10m`, `15m`, `30m`, `1h`.

### Comparison Operators

The `comparison` variable controls how the measured value is compared to the threshold. Valid values: `greater_than`, `less_than`.

For `down` and `down_global` alert types the threshold represents the number of probe regions reporting the endpoint as down. For `latency` it is a millisecond value. For `ssl_expiry` it is the number of days until expiry.

---

## Resource Alerts (Droplet Metrics)

Resource alerts are created via the `digitalocean_monitor_alert` resource. They monitor infrastructure-level metrics for specific Droplets or resource tags.

The `resource_alerts` variable accepts a map where each entry defines one alert:

```hcl
resource_alerts = {
  "cpu-alert" = {
    alerts = [
      {
        email = ["ops@example.com"]
        slack = [{ channel = "alerts", url = "https://hooks.slack.com/..." }]
      }
    ]
    type        = "v1/insights/droplet/cpu"
    compare     = "GreaterThan"
    value       = 95
    window      = "5m"
    enabled     = true
    entities    = ["<droplet-id>"]
    description = "CPU usage above 95%"
    tags        = ["production"]
  }
}
```

### Supported Metric Types

Common values for the `type` field:

| Metric type string                       | Description                    |
|------------------------------------------|--------------------------------|
| `v1/insights/droplet/cpu`                | CPU utilization percentage     |
| `v1/insights/droplet/memory_utilization_percent` | Memory utilization    |
| `v1/insights/droplet/disk_utilization_percent`   | Disk utilization      |
| `v1/insights/droplet/public_outbound_bandwidth`  | Outbound bandwidth    |
| `v1/insights/droplet/load_1`             | 1-minute load average          |

---

## Notification Channels

Both uptime alerts and resource alerts support two notification channels:

### Email

Provide a list of email addresses:

```hcl
notifications = [
  {
    email = ["team@example.com", "oncall@example.com"]
  }
]
```

### Slack

Provide a Slack webhook URL and channel name:

```hcl
notifications = [
  {
    slack = [
      {
        channel = "alerts"
        url     = "https://hooks.slack.com/services/..."
      }
    ]
  }
]
```

Both email and Slack can be specified in the same notification block.

---

## Operational Checklist

- Use `down_global` as the default `alert_type` to avoid false positives from single-region probe failures.
- Set `period` to at least `2m` to avoid noise from transient failures.
- Use `https` as the check type for any endpoint that serves TLS traffic; add an `ssl_expiry` alert with a threshold of at least 30 days.
- Place resource alerts on critical Droplets by specifying their IDs in `entities`, or use `tags` to apply alerts to groups of Droplets dynamically.
- Store Slack webhook URLs in environment variables or a secrets manager rather than in plain-text configuration.
- Set `enable = false` to temporarily disable all uptime checks without destroying resources.
- Review `threshold` and `comparison` values carefully for `latency` alerts; the appropriate threshold depends on the expected response time baseline.
- Use separate module invocations (or separate entries in `resource_alerts`) for CPU, memory, disk, and bandwidth to keep alert configurations independent.
