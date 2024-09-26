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
        sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
        sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
        sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
        sudo iptables -A INPUT -p udp --dport 123 -m limit --limit 10/sec --limit-burst 20 -j ACCEPT

    done
done

# Save the rules
sudo iptables-save > /etc/iptables/rules.v4

# Edit crontab
crontab -e

# Add the following line to run the script every hour
0 * * * * /path/to/blacklist.sh
