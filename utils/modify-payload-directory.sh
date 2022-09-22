#!/bin/bash

# COLORS
#RED_FG="\033[1;31m"
GREEN_FG="\033[1;32m"
#BLUE_FG="\033[1;34m"
MAGENTA_FG="\033[1;35m"
#CYAN_FG="\033[1;36m"
RESET="\033[0m"

# Get line from apache2.conf with current name of payload directory
current_dir=$(grep 'Alias' < /tools/megazord-composition/src/apache2/apache2.conf)

# Get value of PAYLOAD_DIR from .env file
updated_dir="$(grep 'PAYLOAD_DIR' < /tools/megazord-composition/.env \
  | cut -d '=' -f 2)"

updated_line="Alias $updated_dir \"/var/www/uploads\""

echo "[*] Updating hosted payload directory to: $updated_dir"

# replace old uploads directory name with new name
sed -i "s|${current_dir}|${updated_line}|" \
  /tools/megazord-composition/src/apache2/apache2.conf

echo -e "${GREEN_FG}[\U2714] Updated name of payload directory to:${RESET}\
 ${MAGENTA_FG}$updated_dir${RESET}\n"

# If apache is already running, restart the container
if sudo docker ps | grep 'apache' > /dev/null; then
  echo "[*] Restarting apache container"

  sudo docker restart apache cobalt

  echo -e "${GREEN_FG}[\U2714] Apache container successfully restarted"
fi
