#!/bin/bash
cd /tmp
wget -O splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm 'https://d7wz6hmoaavd0.cloudfront.net/products/universalforwarder/releases/8.2.1/linux/splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm'
su -c "sed -i 's/# %wheel/%wheel/g' /etc/sudoers"
sudo dnf install nano nmap vim wget -y

sudo dnf install splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm -y
sudo cat <<EOT >> /opt/splunkforwarder/etc/system/local/user-seed.conf
[user_info]
USERNAME = admin
PASSWORD = splunk123!
EOT

sudo ln -s /opt/splunkforwarder/bin/splunk /usr/bin/splunk

sudo /opt/splunkforwarder/bin/splunk restart --accept-license --answer-yes --no-prompt
sudo /opt/splunkforwarder/bin/splunk add forward-server splunk:9997 -auth admin:splunk123!
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/messages
sudo /opt/splunkforwarder/bin/splunk add monitor /etc/sudoers

sudo ansible-galaxy collection install awx.awx

sudo ansible-playbook /home/rhel/splunk-demo/configure_tower.yml
