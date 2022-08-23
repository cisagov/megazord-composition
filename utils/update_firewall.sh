#! /bin/bash

USAGE="\

This script can be used to modify ufw or iptables rules to limit access
to the teamserver to hosts with a cloudfront IP and hosts listed in a
file.

Usage:
$0 (ufw | iptables) (on | off) (IP_LIST_FILE)

         ufw - update ufw tables
    iptables - updates iptables DOCKER chain

          on - Adds rules to the firewall
         off - Removes rules from firewall

IP_LIST_FILE - File containing IP addresses of hosts to grant access to teamserver
"

ALLOW_IPS=(
10.224.80.9
10.224.80.230
)

if [ $# = 0 ]; then
    echo "$USAGE"
    exit 1
fi


awsips_filename=cloudfront.txt
if [ ! -f "$awsips_filename" ]; then
    curl \
        https://raw.githubusercontent.com/KyleEvers/awsips/main/cloudfront.txt \
        > $awsips_filename
fi


if [ "$1" = "ufw" ]; then
    if [ "$2" = "off" ]; then
        num_lines=$(($(wc -l $awsips_filename | cut -d ' ' -f 1) + ${#ALLOW_IPS[@]}))
        num_rules=$(sudo ufw status numbered | tail -2 | head -1 | cut -d ' ' -f 1)
        num_rules=${num_rules:1:-1}
        
        if (( $num_rules < $num_lines ));
        then
            echo "No rules to remove."; exit 1
        fi

        for i in $(seq 1 $num_lines);
            do echo 'y' | sudo ufw delete 1;
        done
    
    elif [ "$2" = "on" ]; then
        
        cat $awsips_filename | \
            while read line;
                do sudo ufw insert 1 allow from $line;
            done

        for IP in "${ALLOW_IPS[@]}"
        do
            sudo ufw insert 1 allow from "$IP"
        done
    fi
elif [ "$1" = "iptables" ]; then
    if [ "$2" = "off" ]; then
        num_lines=$(($(wc -l $awsips_filename | cut -d ' ' -f 1) + ${#ALLOW_IPS[@]}))
        num_rules=$(sudo iptables -L DOCKER --line-numbers | tail -1 | cut -d ' ' -f 1)
        
        # If DOCKER chain is empty, then num_rules = 'num'
        # Otherwise check if number of rules in DOCKER chain is less than
        # number of ips to remove.
        if [ "$num_rules" = "num" ] || (( $num_rules < $num_lines ));
        then
            echo "No rules to remove."; exit 1
        fi
 
        for i in $(seq 1 $num_lines);
            do sudo iptables -D DOCKER 1;
        done
    
    elif [ "$2" = "on" ]; then

        for IP in "${ALLOW_IPS[@]}"
        do
            sudo iptables -I DOCKER 1 -s "$IP" -j ACCEPT
        done

        # Reject all others. Add here so this rule immediately follows
        # all cloudfront IPs
        sudo iptables -I DOCKER 3 -j DROP
        
        # Add rule to DOCKER chain that accepts incomming traffic
        # from cloudfront IPs
        cat $awsips_filename | \
            while read line;
                do sudo iptables -I DOCKER 3 -s $line -j ACCEPT;
            done
    fi
fi


backup=(
"allow 22/tcp"
"allow 25/tcp"
"allow 587/tcp"
"allow 993/tcp"
"allow 5000:5999/tcp"
"allow 5901/tcp"
"allow 50050/tcp"
"deny 53/tcp"
"deny 80/tcp"
"deny 443/tcp"
"deny 8080/tcp"
"deny 53/udp"
"deny 8080/udp"
)
