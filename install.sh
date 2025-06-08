#!/usr/bin/env bash
# WebSploit installation script
# Author: Omar Ωr Santos
# Web: https://websploit.org
# X: @santosomar LinkedIn: https://linkedin.com/in/santosomar
# Version: 4.1


clear

print_banner() {
    # Define Colors and Styles using tput
    local bold reset blue green yellow cyan
    bold=$(tput bold)
    reset=$(tput sgr0) # Resets all attributes

    # Check if terminal supports colors (at least 8)
    if [[ $(tput colors) -ge 8 ]]; then
        blue=$(tput setaf 4)
        # green=$(tput setaf 2) # Uncomment if you want to use green later
        yellow=$(tput setaf 3) # Good for prompts
        cyan=$(tput setaf 6)   # Nice for titles or key info
    else
        # Set to empty if no color support; bold might still work
        blue=""
        green=""
        yellow=""
        cyan=""
        reset=""
    fi

    clear
    # Use cyan for the top/bottom separators and title
    echo "${bold}${blue}======================================================================${reset}"
    echo "${bold}${cyan}                WebSploit Labs Installer (v4.0)${reset}"
    echo "${bold}${blue}======================================================================${reset}"
    echo # Blank line for spacing

    # Use bold for labels, standard text for values, blue for URL
    echo " ${bold}Author:${reset}  Omar Ωr Santos"
    echo " ${bold}Web:${reset}     ${blue}https://websploit.org${reset}" # Make URL stand out
    echo " ${bold}Twitter:${reset} @santosomar"
    echo # Blank line

    # Description in standard text
    echo " This script will install the tools, configurations, and Docker"
    echo " containers required for the WebSploit Labs learning environment."
    echo # Blank line
    echo "----------------------------------------------------------------------"
    echo # Blank line

    # Use yellow for the prompt to draw attention
    read -n 1 -s -r -p "${yellow}Press any key to continue the setup...${reset}"
    echo # Add a newline after the keypress for cleaner subsequent output
}

print_banner

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

#--------------------------------------------------
# 1) Check if running as root
#--------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "You need admin privileges in order to install these packages. Please run this script as root (e.g. sudo ./install.sh). Additional details at https://websploit.org"
  exit 1
fi

#--------------------------------------------------
# 2) Basic apt update & install
#--------------------------------------------------
echo "[+] Updating apt and installing base packages..."
apt update -y
apt install -y wget curl git python3-pip python3-venv

#--------------------------------------------------
# 3) Install Python-based tools via apt (where possible)
#    This avoids PEP 668 issues for commonly packaged tools
#--------------------------------------------------
echo "[+] Installing Python-based tools via apt where available..."
apt install -y python3-flake8 python3-flask

#--------------------------------------------------
# 4) Installing docker and pulling the docker-compose.yml
#--------------------------------------------------

echo "[+] Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker --now

# Chnage this to checking for docker-compose.yml file exists, if not then error out with error message echo "[+] Fetching docker-compose.yml from WebSploit.org..."

echo "[+] Starting containers..."
cd /root
docker-compose -f docker-compose.yml up -d


#--------------------------------------------------
# 5) Add bridge for the docker env
#--------------------------------------------------
sudo ip link add macvlan-shim link ens18 type macvlan mode bridge
sudo ip addr add 10.10.1.100/24 dev macvlan-shim
sudo ip link set macvlan-shim up

#--------------------------------------------------
# 6) Container info script
#--------------------------------------------------
echo "[+] Installing 'containers' script..."
bash containers.sh
#--------------------------------------------------
# Done
#--------------------------------------------------
echo "
[✔] All done! All tools, apps, and containers have been installed and setup.
Have fun hacking! - Omar (Ωr) Santos
"
