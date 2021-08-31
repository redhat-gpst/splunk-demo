#!/bin/bash
cd /tmp

## this script is for reference and has been converted to an ansible playbook

## audit access to /etc/sudoers
sudo auditctl -w /etc/sudoers -p wa -k sudoers

## install some programs
sudo dnf install nano nmap vim wget -y

## download and install splunk forwarder
sudo wget -O splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm 'https://d7wz6hmoaavd0.cloudfront.net/products/universalforwarder/releases/8.2.1/linux/splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm'
sudo dnf install splunkforwarder-8.2.1-ddff1c41e5cf-linux-2.6-x86_64.rpm -y

## create user-seed.conf file for splunk 
sudo cat <<EOT >> /opt/splunkforwarder/etc/system/local/user-seed.conf
[user_info]
USERNAME = admin
PASSWORD = splunk123!
EOT

## create symlink to splunk binary
sudo ln -s /opt/splunkforwarder/bin/splunk /usr/bin/splunk

## configure splunk forwarder to monitor /var/log/messages and audit.log
sudo /opt/splunkforwarder/bin/splunk restart --accept-license --answer-yes --no-prompt
sudo /opt/splunkforwarder/bin/splunk add forward-server splunk:9997 -auth admin:splunk123!
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/messages
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/audit/audit.log

## configure Ansible atuomation controller
sudo ansible-galaxy collection install splunk.es
sudo ansible-galaxy collection install awx.awx
sudo ansible-playbook /home/rhel/splunk-demo/configure_tower.yml
