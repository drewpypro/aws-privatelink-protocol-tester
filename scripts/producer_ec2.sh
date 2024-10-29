#!/bin/bash

# Fetch public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Set hostname
HOSTNAME="producer-$PUBLIC_IP"
sudo hostnamectl set-hostname $HOSTNAME
sudo hostnamectl 

# Update /etc/hosts
echo "127.0.0.1   $HOSTNAME" | sudo tee -a /etc/hosts

# Ensure the hostname is applied immediately for the current session
export PS1="[\u@$HOSTNAME \W]\$ "

ssh-keygen -t rsa -f /home/ec2-user/server_rsa_key -N ""
chmod 600 /home/ec2-user/server_rsa_key

sudo useradd testuser
echo "testuser:testpassword" | sudo chpasswd

mkdir -p /home/ec2-user/.ssh
echo '${public_key}' >> /home/ec2-user/.ssh/authorized_keys
chown -R ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/authorized_keys

sudo rm /usr/lib/motd.d/10-uname
sudo rm /usr/lib/motd.d/20-*  # Remove any other MOTD scripts

sudo sed -i 's/#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Load python script
cat <<'EOF' > /home/ec2-user/tcp_udp_services.py
${producer_script}
EOF


ASCII_ART='  ______   __       __   ______  
 /      \ |  \  _  |  \ /      \ 
|  $$$$$$\| $$ / \ | $$|  $$$$$$\
| $$__| $$| $$/  $\| $$| $$___\$$
| $$    $$| $$  $$$\ $$ \$$    \ 
| $$$$$$$$| $$ $$\$$\$$ _\$$$$$$\
| $$  | $$| $$$$  \$$$$|  \__| $$
| $$  | $$| $$$    \$$$ \$$    $$
 \$$   \$$ \$$      \$$  \$$$$$$ '


# Create the new banner content directly into the file
{
  echo ""
  echo "$ASCII_ART"    
  echo ""
  echo "Welcome to the Producer VM."
  echo "Use the following command to show usage:"
  echo "python3 tcp_udp_services.py"
  echo ""
} | sudo tee /usr/lib/motd.d/30-banner

{
  echo "[Unit]"
  echo "Description=Basic TCP/UDP Tester Application"
  echo ""
  echo "[Service]"
  echo "ExecStart=/usr/bin/python3 /home/ec2-user/tcp_udp_services.py"
  echo "Restart=always"
  echo "AmbientCapabilities=CAP_NET_BIND_SERVICE"
  echo ""
  echo "User=ec2-user"
  echo ""
  echo "[Install]"
  echo "WantedBy=multi-user.target"
} | sudo tee /etc/systemd/system/tcp_udp_services.service


sudo systemctl daemon-reload

# Install required packages
sudo yum update -y
sudo yum install -y python3 python3-pip

# Install SSM Agent
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install required python packages
pip3 install argparse paramiko

# Start and enable services
sudo systemctl start tcp_udp_services
sudo systemctl enable tcp_udp_services
