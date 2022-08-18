#!/bin/bash

current_dir=$(grep 'Alias' < ~/megazord-composition/src/apache2/apache2.conf)

echo "$current_dir"

updated_dir="Alias $(grep 'PAYLOAD_DIR' < ~/megazord-composition/.env | cut -d '=' -f 2) \"/var/www/uploads\""

echo "Updated name of directory where payloads are hosted to- $updated_dir"

sed -i "s|${current_dir}|${updated_dir}|" ~/megazord-composition/src/apache2/apache2.conf
