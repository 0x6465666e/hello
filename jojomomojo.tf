job "jojomomojo" {
  region      = "global"
  datacenters = ["jojomomojo"]
  namespace   = "defn"
  type        = "service"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert      = false
    canary           = 0
  }

  group "demo" {
    count = 2

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    ephemeral_disk {
      sticky  = true
      migrate = true
      size    = 300
    }

    task "whoami" {
      driver = "docker"

      config {
        image = "containous/whoami"
        args  = ["--port", "${NOMAD_PORT_whoami}"]
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          port "whoami" {}
        }
      }

      service {
        name = "defn-whoami"
        port = "whoami"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.defn-whoami.entrypoints=https",
          "traefik.http.routers.defn-whoami.rule=HostRegexp(`defn-whoami.{domain:.+}`)"
        ]
      }
    }
  }
}
