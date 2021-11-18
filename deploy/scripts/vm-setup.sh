#!/bin/bash

# Download binaries
curl -L -o LiveInstanceDemo.tar.gz '{{{ArtifactURL}}}'
mkdir /bin/liveinstancedemo/
tar -xf ./LiveInstanceDemo.tar.gz -C /bin/liveinstancedemo
rm -f LiveInstanceDemo.tar.gz
chmod +x /bin/liveinstancedemo/LiveInstanceDemo

# Create service
cat > /etc/systemd/system/liveinstancedemo.service <<EOF
[Unit]
Description=LiveInstanceDemoLinux
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=20
TimeoutSec=600t
ExecStart=/bin/liveinstancedemo/LiveInstanceDemo --urls=http://0.0.0.0:5000
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
WorkingDirectory=/bin/liveinstancedemo/
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable liveinstancedemo
systemctl start liveinstancedemo