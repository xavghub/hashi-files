###### I could only find Grafana Nomad job dating 6y ago
###### The following job is an updated version of basic Grafana version
###### Tested on Nomad v1.7.5&6

job "grafana" {
  datacenters = ["*"] ###### * is used as wildcard for any datacenter name ######
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "grafana" {
    restart {
      attempts = 10
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }
		network {
      port "grafana-http" {
        to = 3000 ###### Internal Docker port ######
      }
      mode = "bridge"
    }
    
    task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana"
      }

      env {
        GF_LOG_LEVEL = "DEBUG"
        GF_LOG_MODE = "console"
        GF_SERVER_HTTP_PORT = "${NOMAD_PORT_http}"
        GF_PATHS_PROVISIONING = "/local/provisioning"
      }

      artifact {
        source      = "github.com/burdandrei/nomad-monitoring/examples/grafana/provisioning"
        destination = "local/provisioning/"
      }

      artifact {
        source      = "github.com/burdandrei/nomad-monitoring/examples/grafana/dashboards"
        destination = "local/dashboards/"
      }

      resources {
        cpu    = 1000
        memory = 256
      }

###### Following service block is for Consul Health Check ######
      service {
        name = "grafana"
        port = "grafana-http"
        check {
          name     = "Grafana HTTP"
          type     = "http"
          path     = "/api/health"
          interval = "5s"
          timeout  = "2s"
           check_restart {
            limit = 2
            grace = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}
