provider "digitalocean" {}

##------------------------------------------------
## alert module call.
##------------------------------------------------
module "uptime-alert" {
  source        = "./../.."
  name          = "app"
  environment   = "test"
  uptime_alerts = true
  target_url    = "http://test.do.clouddrove.ca/"
  type          = "http"
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
