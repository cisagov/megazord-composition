#! /bin/bash

### IP ALLOW LIST ###
# Update this list with IPs of hosts you want to be
# able to communicate with the teamserver
ALLOW_IPS=(
  10.224.80.9
  10.224.80.230
)
###

USAGE="\

This script can be used to modify iptables rules to limit teamserver access
to hosts with a cloudfront IP and hosts listed in a file.

Usage:
$0 (on | off | all)

          on - Adds rules to the firewall
	  	Specifically the rules added will accept traffic from all cloudfront IPs,
		all hosts in the ALLOW_IPS list, and drops all other
         off - Removes rules from firewall that were added by the script
	 all - Adds a single rule to the DOCKER chain to drop all external traffic

"

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

if [ "$1" = "all" ]; then
  # Drop all traffic
  sudo iptables -I DOCKER 1 -j DROP
elif [ "$1" = "off" ]; then
  # Get number of lines in the aws IPs file
  #  + number of IPs in ALLOW_IPS list + 1 (rule to drop all traffic)
  num_lines=$(($(wc -l $awsips_filename | cut -d ' ' -f 1) + ${#ALLOW_IPS[@]} + 1))
  # Get number of rules currently in the DOCKER chain
  num_rules=$(sudo iptables -L DOCKER --line-numbers | tail -1 | cut -d ' ' -f 1)

  # If DOCKER chain is empty, then num_rules = 'num'
  # Otherwise check if number of rules in DOCKER chain is less than
  # number of ips to remove.
  if [ "$num_rules" = "num" ] || ((num_rules < num_lines)); then
    echo "No rules to remove."
    exit 1
  fi

  idx=0
  until [ $idx -eq $num_lines ]; do
    sudo iptables -D DOCKER 1
    ((idx++))
  done
elif [ "$1" = "on" ]; then
  # Iterate over IPs in the ALLOW_IP list to add rules for accepting traffic
  for IP in "${ALLOW_IPS[@]}"; do
    sudo iptables -I DOCKER 1 -s "$IP" -j ACCEPT
  done

  # Drop  all others. Added here so this rule immediately follows
  # all cloudfront IPs and the IPs in the ALLOW_IPS list
  sudo iptables -I DOCKER 3 -j DROP

  # Add rule to DOCKER chain that accepts incomming traffic
  # from cloudfront IPs
  while read -r line; do
    sudo iptables -I DOCKER 3 -s "$line" -j ACCEPT
  done < $awsips_filename
fi
