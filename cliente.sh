#!/bin/bash
echo "Instalar LXD"
sudo snap install lxd

echo "agregar usuario"
sudo gpasswd -a vagrant lxd

echo "creando Preseed file"
cat >> lxd2config.yalm << EOF

config:
  core.https_address: 172.42.42.102:8443
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 10.0.2.0/24
  description: ""
  managed: true
  name: lxdfan0
  type: bridge
storage_pools:
- config:
    source: ""
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
cluster:
  server_name: clienteUbuntu
  enabled: true
  member_config: []
  cluster_address: 172.42.42.101:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIFRDCCAyygAwIBAgIRAPSFbpgix58Spo2WEFwEYsUwDQYJKoZIhvcNAQELBQAw
    MzEcMBoGA1UEChMTbGludXhjb250YWluZXJzLm9yZzETMBEGA1UEAwwKcm9vdEBz
    ZXJ2MTAeFw0yMTEwMjgxNzIxNTVaFw0zMTEwMjYxNzIxNTVaMDMxHDAaBgNVBAoT
    E2xpbnV4Y29udGFpbmVycy5vcmcxEzARBgNVBAMMCnJvb3RAc2VydjEwggIiMA0G
    CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDo0sjE076TzSx/LqVno3YSLETQoFBN
    BygqnBNrhj8lGRvqgR8/xz0JiAMGAyrbzbR5sa8ejpTW+zbcXKYfP6xWF7eLKei4
    MjozIoqOOHnLYFha90k5tjDQEL3Z7iF+jtjfkSLrKqnOTahNhXYXKTtUpa3RmSxa
    6MTIewYynHRCLtfd9G7GeZxHBDX6SgicPoIMxWh2pBCSBIYiVgK1HFFgrUE9Jb5q
    4mAETohivgz8qaREaiSDX2ZXAjVXenA+ihKR2qzUhnOS6v06HmjWnmoe2Y6c4BnJ
    b2B9SHutgzeESk72lGP6GIeHVNDImwEPxs6V+ga5fAIZM2nhz6tbl2sFP1jzMOsF
    XXSnGNGd1Dug6GxFCmV+XWvlKNlLQt6/A2YBVNT085+99zdvauKVjS2OJ4adqES0
    toJjFKdjbsPL6C2OsTnBPBCnPD2Tf7uRh1eWxPe3wYgwtHK1+o1t/oV9B2IuU5P1
    D7a6NrWZG+Fl0GZHCrPuNMhbLxvNuuC+zoafQ7LfH7D//32B5UTJG1SxuZ24yhCj
    f+HZLBahg30DLnjqUWFh76nNwGb7TdfCuAoJ6ItXq9lef+2N3NsH8IoxnXs4i5pR
    Af8+PhZp5fmEaQxRokq4NBbroDTrUdrvyRs8q3DmcEuukK/V8QgGMdkKRB1f6QGs
    /X0OdU7PhE/YnQIDAQABo1MwUTAOBgNVHQ8BAf8EBAMCBaAwEwYDVR0lBAwwCgYI
    KwYBBQUHAwEwDAYDVR0TAQH/BAIwADAcBgNVHREEFTATggVzZXJ2MYcECgACD4cE
    rCoqZTANBgkqhkiG9w0BAQsFAAOCAgEAUGUit3zYTWOR58ExxsaRUcHHfS9qDrol
    Z0aBX+eZLyXKUCGs4JRAE2P/1VyE6eqKcd++q3KkCsOMlwhLKkRZRxRohJsPoHb1
    w7Fwi6+jv47zzc62CQpXId0mioHwxlJTKarzvtGKOZhFvJc/eVGvNA03wGAemsB5
    4Xd32z05/1syoudpJCiEmvVRnbwRrf8yVZJed401juQqnUW/+9bfOyxkicFjvXZ/
    UH8UoW29ADH3nKbo/RfkZ04ds6HEEcXHms64xcrrhr14B8VagLIDQSW9D32+JoGH
    YRKzFoLgyc72F37+5TSbM6hAuZcY0Tq8kwYGA90z2U7Vz/b4LFLAuYih461nFw6h
    sN5JngJzxwGF7bT/jNDbWwxJf1VzDniwc766hCjvszv1MP0MkYmFRKAG5Um9VU9V
    Mp76upvTkhSI9wGBkTvOesapa+412ghdLxShQx0sRg67cXAL7HdA+JM5ue+07F0W
    qlhEsuB7nUA6b4Q70nBN+sqlTr5nwmcqmQxj6NCXB8uPVRMorfJC21+tfBIqTJ8E
    EcanDoedN82j/zhr348Y4i0sVim68fPCdgYlE7Eo8slw9MGjRqf3z/SPhJM6XcQM
    owyieKO1NVV/eLfiz+m9jSpvSjm3jYrLeKUNrB1lTrSMf/k2/N07eMwxodI/iFza
    do+fd7QYjP4=
    -----END CERTIFICATE-----
  server_address: ""
  cluster_password: 123
EOF

echo"usar preseed"
cat lxd2config.yaml | sudo lxd init --preseed

echo "crear contenedores "
lxc init ubuntu:18.04 web1 --target clienteUbuntu
lxc init ubuntu:18.04 backup1 --target clienteUbuntu

echo "iniciar contenedores"
lxc start web1
lxc start backup1

echo "instalar apache2"

lxc exec web1 -- apt-get install apache2 -y
lxc exec backup1 -- apt-get install apache2 -y

echo "crear index.http"

cat >> index.html<< EOF
Bienvenido al contenedor LXD1
EOF
lxc file push index.html web1/var/www/html/index.html

cat >> index.html << EOF
Bienvenido al contenedor de backup 1
EOF

lxc file push index.html web1/var/www/html/index.html

echo "redireccionamiento de puertos"
lxc config device add web1 myport80 proxy listen=tcp:172.42.42.102:5080 connect=tcp:127.0.0.1:80
lxc config device add backup1 myport80 proxy listen=tcp:172.42.42.102:6080 connect=tcp:127.0.0.1:80

echo "reiniciar apache2"
lxc exec web1 -- systemctl restart apache2
lxc exec backup1 -- systemctl restart apache2
