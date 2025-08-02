Save this script as blacklist.sh, make it executable (chmod +x blakclist.sh), and run it whenever needed.
or
Run chmod 777 *
Run ./blacklist.sh

Or use tablesonly.sh if you dont want clutter or worrying about dropping alot of domains and ips.

This script currently blocks 98% of free attacks from


https://stresse.ru


https://stresserst.su


https://quezstresser.ru


new geyser exploit fix diffrent methods.

This rule limits new connections from a single IP:

sudo iptables -A INPUT -p tcp --dport 24555 -m connlimit --connlimit-above 3 -j REJECT

🔍 Explanation:

    --dport 24555: Replace 24555 with your game server's port.

    --connlimit-above 3: Allows up to 3 simultaneous connections per IP.

    REJECT: Drop excess connections.

You can make it stricter or looser by adjusting the number.

To remove the rule later:

sudo iptables -D INPUT -p tcp --dport 24555 -m connlimit --connlimit-above 3 -j REJECT

✅ 2. Using nftables (Modern Alternative)

If you're using nftables instead of iptables (common on newer systems):

sudo nft add rule ip filter input tcp dport 24555 ct count over 3 drop

You may need to define a table and chain first if not already configured.
✅ 3. Application-Level (Best Option if Supported)

If your server software (e.g., game server like Minecraft, etc.) supports IP join limits natively, always prefer that, because:

    It's more precise

    It handles UDP-based connections more accurately (iptables can miss these)

    It allows whitelisting or exception handling


netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head

This shows top IPs by active connection count.

-Maddison<3
