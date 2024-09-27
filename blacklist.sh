#!/bin/bash

# Domains to block
DOMAINS=("ntis.gov" "tcnb.com" "noaa.gov" "aoc.gov" "cfpb.gov" "fnal.gov" "rfmw.com" "osac.gov" "uwgb.edu" "vcor.com")

for DOMAIN in "${DOMAINS[@]}"
do
    echo "Resolving IPs for domain: $DOMAIN"
    IPS=$(dig +short $DOMAIN)
    if [ -z "$IPS" ]; then
        echo "No IPs found for domain: $DOMAIN or DNS resolution failed."
        continue
    fi
    for IP in $IPS
    do
        echo "Blocking IP: $IP"
        sudo iptables -A INPUT -s $IP -j DROP
        sudo iptables -A OUTPUT -d $IP -j DROP 
    done
done

# Adding and Saving the rules
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
sudo iptables -A INPUT -p udp --dport 123 -m limit --limit 10/sec --limit-burst 20 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 80 -j DROP
# Limit ICMP echo requests (ping) to 1 per second, with a burst of 5
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 5 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
# Limit UDP traffic to 10 packets per second per IP
sudo iptables -A INPUT -p udp -m limit --limit 10/s -j ACCEPT
sudo iptables -A INPUT -p udp -j DROP
# Drop NULL packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# Drop XMAS packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
# Drop FIN scan packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN -j DROP
# Allow a maximum of 10 connections per IP
sudo iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 10 -j REJECT --reject-with tcp-reset
# Rate limit incoming traffic to 50 packets per second
sudo iptables -A INPUT -m limit --limit 50/s --limit-burst 100 -j ACCEPT
sudo iptables -A INPUT -j DROP
sudo apt update
sudo apt install arptables
sudo arptables -A INPUT --opcode 2 -j DROP
sudo sed -i -e '$i \arptables-restore < /etc/arptables.rules\n' /etc/rc.local
sudo chmod +x /etc/rc.local
sudo sh -c "arptables-save > /etc/arptables.rules"
sudo iptables-save > /etc/iptables/rules.v4

# Edit crontab
crontab -e

# Add the following line to run the script every hour
0 * * * * /path/to/blacklist.sh
