#!/bin/bash
# Remove resolvconf
apt remove resolvconf -y

# Enable systemd-resolved
systemctl enable --now systemd-resolved

# Point /etc/resolv.conf to systemd-resolved's stub
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
mkdir -p /etc/systemd/resolved.conf.d/
cat > /etc/systemd/resolved.conf.d/dns.conf << 'EOF'
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8 8.8.4.4
DNSOverTLS=yes
EOF

systemctl restart systemd-resolved
resolvectl status
resolvectl query google.com
rm /etc/network/if-up.d/resolved /etc/network/if-down.d/resolved
