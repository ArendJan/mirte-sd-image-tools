#!/bin/bash 

# Install wifi-connect
bash <(curl -L https://github.com/balena-io/wifi-connect/raw/master/scripts/raspbian-install.sh)
systemctl disable systemd-resolved
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt install -y dnsmasq
systemctl disable dnsmasq # will be enabled by wifi-connect

# Added systemd service to account for fix: https://askubuntu.com/questions/472794/hostapd-error-nl80211-could-not-configure-driver-mode
echo '[Unit]' >> /lib/systemd/system/zoef_ap.service
echo 'Description=Zoef Wifi AP' >> /lib/systemd/system/zoef_ap.service
echo 'After=network.target' >> /lib/systemd/system/zoef_ap.service
echo 'After=ssh.service' >> /lib/systemd/system/zoef_ap.service
echo 'After=network-online.target' >> /lib/systemd/system/zoef_ap.service
echo '' >> /lib/systemd/system/zoef_ap.service
echo '[Service]' >> /lib/systemd/system/zoef_ap.service
echo 'ExecStart=/bin/bash -c "/home/zoef/zoef_sd_card_image/network_setup.sh"' >> /lib/systemd/system/zoef_ap.service
echo '' >> /lib/systemd/system/zoef_ap.service
echo '[Install]' >> /lib/systemd/system/zoef_ap.service
echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_ap.service

systemctl enable zoef_ap

# Add zoef user with sudo rights
useradd -m -G sudo -s /bin/bash zoef
echo -e "zoef_zoef\nzoef_zoef" | passwd zoef
passwd --expire zoef

# Disable ssh root login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Add avahi daemon to enable http://zoef.local
sudo apt-get install -y avahi-daemon
echo "zoef" > /etc/hostname
