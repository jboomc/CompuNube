#!/bin/bash
echo "Instalar LXD"
sudo snap install lxd

echo "agregar usuario"
sudo gpasswd -a vagrant lxd

echo "creando Preseed file"

cat >> lxd1config.yalm << EOF
  config:
   core.https_address: 172.42.42.101:8443
   core.trust_password: 123
  networks:
  - config:
    bridge.mode: fan
    fan.underlay_subnet: auto
  description: ""
  managed: false
  name: lxdfan0
  type: ""
storage_pools:
- config: {}
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
cluster:
  server_name: servidorUbuntu
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""

EOF

echo"usar preseed"
cat lxd1config.yaml | lxd init --preseed

echo "crear contenedor haproxy"
lxc init ubuntu:18.04 haproxy --target servidorUbuntu
lxc start haproxy

echo "ingresar a haproxy"
lxc exec haproxy /bin/bash
apt update && apt upgrade -y
apt install haproxy -y
exit

echo "creando haproxy.cfg"
cat >> haproxy.cfg<< EOF

global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	# An alternative list with additional directives can be obtained from
	#  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/sorry.http
	errorfile 504 /etc/haproxy/errors/504.http


backend web-backend
   balance roundrobin
   stats enable
   stats auth admin:admin
   stats uri /haproxy?stats
     option allbackups
   server web1  172.42.42.102:5080 check
   server web2  172.42.42.103:5080 check
   server backup1 172.42.42.102:6080 check backup
   server backup2 172.42.42.103:6080 check backup 

frontend http
  bind *:80
  default_backend web-backend
EOF

echo "copiar archivo dentro del contenedor"
lxc file push haproxy.cfg haproxy/etc/haproxy/haproxy.cfg

echo "crear archivo de disculpa"
cat >> sorry.http << EOF

HTTP/1.0 200 OK
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html>
<body>
<h1>Pagina de disculpa</h1>
No hay servidores ni contenedores disponibles
</body>
</html>
EOF

echo "copiar archivo de disculpa al contenedor"
lxc file push sorry.http haproxy/etc/haproxy/errors/sorry.http

echo "reenvio de puertos"
lxc config device add haproxy http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80

echo "reiniciar haproxy service"
lxc exec haproxy -- systemctl haproxy restart
