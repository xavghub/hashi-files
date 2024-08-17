job "hello-world-nginx" {
  datacenters = ["*"] #Any datacenters
  group "servers" {
    network {
      port "http" { 
        to = 80         # Any Random port Nomad chooses to use but redirects to port 80 
      }
    }
    count = 1
    task "server" {
     	config {
       	image = "nginx"
       	ports = ["http"]
        volumes = [
      		"conf/default.conf:/etc/nginx/conf.d/default.conf", # mount template modifiction in nomad job to container configuration file
      		"conf/hello.html:/etc/nginx/html/hello.html"  # mount template modifiction in html file in nomad job to container web file
       		]
      	}
      	driver = "docker"

      template {
        data = <<EOF
                      <h1>Hello, Nomad!</h1>
                      <ul>
                        <li>Task: {{env "NOMAD_TASK_NAME"}}</li>
                        <li>Group: {{env "NOMAD_GROUP_NAME"}}</li>
                        <li>Job: {{env "NOMAD_JOB_NAME"}}</li>
                        <li>Metadata value for foo: {{env "NOMAD_META_foo"}}</li>
                        <li>Currently running on port: {{env "NOMAD_PORT_www"}}</li>
                      </ul>
      		EOF
      destination = "conf/hello.html"
                }

      template {
				data = <<EOH
server {
	listen 80;
	server_name  localhost;


  location / { # where is the root folder BASE /etc/nginx so in this case /etc/nginx
    root      html; # which folder in /etc/nginx
		index hello.html; # which base file to display in this folder
  	try_files $uri $uri/ =404;
  }
}
EOH
	destination = "conf/default.conf"
      	}
      service {
      name = "XT-hello-world-nginx"
      port = "http"
    
    # For Traefik path stripping usage
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.helloworldnginx.rule=Path(`/hello-nginx`)", # all resquests coming in with path /hello-nginx associate to this nomad job
        "traefik.http.middlewares.helloworldnginx-strip.stripprefix.prefixes=/hello-nginx", # remove the /hello-nginx path as the webpage is server by "/" path
    	"traefik.http.routers.helloworldnginx.middlewares=helloworldnginx-strip" # add a url path-strip to the router of the nomad job  
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }
	}
  }
}
