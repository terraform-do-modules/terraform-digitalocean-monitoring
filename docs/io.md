# terraform-digitalocean-monitoring — Inputs and Outputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| `environment` | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| `label_order` | Label order, e.g. `name`. | `list(any)` | `["name", "environment"]` | no |
| `managedby` | ManagedBy, e.g. `terraform-do-modules`. | `string` | `"terraform-do-modules"` | no |
| `enable` | A boolean value indicating whether uptime checks and alerts are enabled or disabled. | `bool` | `true` | no |
| `enabled` | A boolean value indicating whether the check is enabled or disabled. | `bool` | `true` | no |
| `target_url` | The list of endpoint URLs to perform health checks on. | `list(any)` | `[]` | no |
| `type` | The type of health check to perform per URL entry: `ping`, `http`, or `https`. | `list(string)` | `[]` | no |
| `regions` | Array of regions from which to perform health checks: `us_east`, `us_west`, `eu_west`, `se_asia`. | `list(string)` | `["us_east", "us_west", "eu_west", "se_asia"]` | no |
| `alert_type` | The type of alert per check: `latency`, `down`, `down_global`, or `ssl_expiry`. | `list(any)` | `["down_global"]` | no |
| `threshold` | The threshold at which the alert enters a trigger state. Meaning depends on alert type. | `list(any)` | `[1]` | no |
| `comparison` | Comparison operator used against the threshold: `greater_than` or `less_than`. | `list(any)` | `["less_than"]` | no |
| `period` | Period the threshold must be exceeded to trigger the alert: `2m`, `3m`, `5m`, `10m`, `15m`, `30m`, or `1h`. | `list(string)` | `["2m"]` | no |
| `notifications` | The notification settings for trigger alerts. Supports `email` (list of addresses) and `slack` (list of `{channel, url}` maps). | `any` | `[]` | no |
| `resource_alerts` | Map of resource alert configurations. Each entry defines `alerts`, `type`, `compare`, `value`, `window`, `enabled`, `entities`, `description`, and `tags`. | `map(any)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `uptime_check_id` | The ID of the first uptime check created. |
| `uptime_alert_id` | The ID of the uptime alert. |
| `uuid` | The full `digitalocean_monitor_alert` resource map for resource alerts. |
