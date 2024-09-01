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

# Save the rules
sudo iptables-save > /etc/iptables/rules.v4
