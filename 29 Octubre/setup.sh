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

cat > /etc/systemd/system/hcr-server-80.service <<'EOF'
[Unit]
Description=HCR Server Port 80
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/hcr
ExecStart=/root/hcr/hcr-server --listen :80 --target 127.0.0.1:22 --transport plain
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hcr-server-80

if command -v ufw >/dev/null 2>&1; then
    ufw allow 8080/tcp
    ufw allow 80/tcp
fi

for service in hcr-server hcr-server-80; do
    systemctl is-active "$service"
    systemctl is-enabled "$service"
done

for port in 80 8080; do
    ss -lntp "sport = :$port" | grep -F '"hcr-server"'
done

echo 'HCR Server instalado correctamente en los puertos 80 y 8080.'
