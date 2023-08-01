provider "digitalocean" {}

##------------------------------------------------
## alert module call.
##------------------------------------------------
module "uptime-alert" {
  source      = "./../.."
  name        = "app"
  environment = "test"
  target_url  = ["http://test.do.clouddrove.ca/", "https://test2.do.clouddrove.ca/"]
  type        = ["http", "https"]
  alert_type  = ["down_global"]
  period      = ["2m", "3m"]
  comparison  = ["less_than"]
  ####
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
