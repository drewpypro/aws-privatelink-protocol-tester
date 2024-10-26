#!/bin/bash

# Fetch public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Set hostname
HOSTNAME="consumer-$PUBLIC_IP"
sudo hostnamectl set-hostname $HOSTNAME
sudo hostnamectl 

# Update /etc/hosts
echo "127.0.0.1   $HOSTNAME" | sudo tee -a /etc/hosts

# Ensure the hostname is applied immediately for the current session
export PS1="[\u@$HOSTNAME \W]\$ "

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
cat <<'EOF' > /home/ec2-user/aws_privatelink_protocol_tester.py
${consumer_script}
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
  echo "Welcome to the VPC Privatelink Tester VM."
  echo "Use the following command to show usage:"
  echo "python3 aws_privatelink_protocol_tester.py"
  echo ""
} | sudo tee /usr/lib/motd.d/30-banner

sudo systemctl daemon-reload

# Install required packages
sudo yum update -y
sudo yum install -y python3 python3-pip

# Install SSM Agent
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install required python packages
pip3 install argparse

