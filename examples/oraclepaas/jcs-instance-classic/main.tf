variable user {}
variable password {}
variable domain {}
variable endpoint {}

provider "oraclepaas" {
  user            = "${var.user}"
  password        = "${var.password}"
  identity_domain = "${var.domain}"
  java_endpoint   = "https://jaas.oraclecloud.com"
}

resource "oraclepaas_java_service_instance" "jcs" {
  name        = "my-terraformed-java-service"
  description = "Created by Terraform"

  edition            = "EE"            // SE EE SUITE
  service_version    = "12cRelease212" // 12cR3 or 12cRelease212 or 11gR1
  metering_frequency = "HOURLY"        // HOURLY MONTHLY
  ssh_public_key     = "${file("~/.ssh/id_rsa.pub")}"

  notification_email = "${var.user}"

  weblogic_server {
    shape = "oc1m"

    database {
      name     = "my-terraformed-database-with-backup"
      username = "sys"
      password = "Pa55_Word"
    }

    admin {
      username = "weblogic"
      password = "Weblogic_1"
    }
  }

  backups {
    cloud_storage_container = "Storage-${var.domain}/my-terraformed-java-service-backup"
    auto_generate           = true
  }
}
