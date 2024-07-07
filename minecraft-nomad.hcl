job "minecraft-nomad" {
  datacenters = ["*"]
  type = "service"
  group "minecraft" {
    count = 1
    network {
      port "minecraft-vanilla-port" {
        to = 25565 ###### Internal Minecraft Docker port ######
        static = 25568 ###### Custom static External Port - Port used when adding Minecraft server in the game ######
      }
      port "minecraft-vanilla-rcon" {
        to = 25575
        static = 25575
      }
      mode = "bridge"
    }

    volume "minecraft-data" {
      type = "host"
      read_only = false
      source = "minecraft-data"
    }

    task "minecraft-server" {
      driver = "docker"
      volume_mount {
        volume = "minecraft-data"
        destination = "/data"
        read_only  = false
      }
      config {
        image = "itzg/minecraft-server"
        ports = ["minecraft-vanilla-port","minecraft-vanilla-rcon"]
      }
      resources {
        cpu    = 3000 # 500 MHz
        memory = 6000 # 6 G
      }
      env {
        EULA = "TRUE"
        VERSION = "1.20.4"  ###### Added to control the Minecraft server Version running in this job ######
      }
      service {
       tags = ["minecraft-nomad"]
			 port = "minecraft-vanilla-port"
       provider = "consul"
			 name = "hashi-Minecraft-Server"
       meta {
         meta = "Minecraft running on Hashi-nomad-cluster"
       }
      }
    }
  }
}
