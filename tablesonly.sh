#!/bin/bash

# Allow only 5 connections per second with a burst of 10 for SSH
sudo iptables -A INPUT -p tcp --dport 22 -m limit --limit 5/s --limit-burst 10 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT --reject-with tcp-reset

# Limit SSH connections to 3 per minute from a single IP
sudo iptables -A INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j REJECT --reject-with tcp-reset

# Exclude SSH (port 22) from the mangle table rule
sudo iptables -t mangle -A PREROUTING -p tcp --dport 22 -j ACCEPT

# Drop non-SYN packets for new connections, excluding SSH (port 22)
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW ! --dport 22 -j DROP

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

# Drop everything else
sudo iptables -A INPUT -j DROP

# ARPTables configuration
sudo apt update
sudo apt install arptables
sudo arptables -A INPUT --opcode 2 -j DROP

# Save the ARP and iptables rules
sudo sed -i -e '$i \arptables-restore < /etc/arptables.rules\n' /etc/rc.local
sudo chmod +x /etc/rc.local
sudo sh -c "arptables-save > /etc/arptables.rules"
sudo iptables-save > /etc/iptables/rules.v4

