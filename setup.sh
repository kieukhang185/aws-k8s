#!/bin/bash
# Setup Tool, dependencies, and Environment Variables

echo "APT Update"
sudo apt-get update

echo "APT Upgrade"
sudo apt-get upgrade -y

echo "Installing dependencies"
sudo apt-get install -y make
sudo snap install terraform --classic
sudo snap install aws-cli --classic

echo "Setup alias for terraform"
echo 'alias tf="terraform"' >> ~/.bashrc
source ~/.bashrc
