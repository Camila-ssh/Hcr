#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    exec sudo bash "$0" "$@"
fi

URL='https://raw.githubusercontent.com/Camila-ssh/Hcr/refs/heads/main/29%20Octubre/hcr-server-linux-amd64.tar.gz'

mkdir -p /root/hcr
cd /root/hcr
curl -fL "$URL" -o /root/hcr-server-linux-amd64.tar.gz
tar -xzvf /root/hcr-server-linux-amd64.tar.gz
chmod +x hcr-server install.sh
./hcr-server -version
./install.sh --port 8080 --transport plain --target 127.0.0.1:22

if command -v ufw >/dev/null 2>&1; then
    ufw allow 8080/tcp
fi

systemctl is-active hcr-server
ss -lntp | grep ':8080'
echo 'HCR Server instalado correctamente en el puerto 8080.'
