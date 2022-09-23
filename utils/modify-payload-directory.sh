#!/bin/bash

# COLORS
#RED_FG="\033[1;31m"
GREEN_FG="\033[1;32m"
#BLUE_FG="\033[1;34m"
MAGENTA_FG="\033[1;35m"
#CYAN_FG="\033[1;36m"
RESET="\033[0m"

# Path to the megazord-composition directory
megazord_path="/tools/megazord-composition/"

# Get the current payload directory from the Apache configuration
current_dir=$(grep 'Alias' < "${megazord_path}"/src/apache2/apache2.conf)

# Get the value of PAYLOAD_DIR from the .env file
updated_dir="$(grep 'PAYLOAD_DIR' < "${megazord_path}"/.env \
  | cut -d '=' -f 2)"

updated_line="Alias $updated_dir \"/var/www/uploads\""

echo "[*] Updating hosted payload directory to: $updated_dir"

# Update the payload directory in the Apache configuration
sed -i "s|${current_dir}|${updated_line}|" \
  "${megazord_path}"/src/apache2/apache2.conf

echo -e "${GREEN_FG}[\U2714] Updated name of payload directory to:${RESET}\
 ${MAGENTA_FG}$updated_dir${RESET}\n"

# If apache is already running, restart the container
if sudo docker ps | grep 'apache' > /dev/null; then
  echo "[*] Restarting apache container"

  sudo docker restart apache cobalt

  echo -e "${GREEN_FG}[\U2714] Apache and Cobalt Strike containers successfully restarted"
fi
