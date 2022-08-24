#!/bin/bash

keystore=domain.store
keystore_path=/opt/cobaltstrike/domain.store
cloudfront_domain=domain.cloudfront.net
domain=domain.com
c2_profile="${domain}-$(date '+%Y-%m-%d').profile"
password=7WTF6WxTG8nPKzB5cXXV4t35CPPsUiXmZBSeXDndhjU=
redirect_location=google.com

# COLORS
RED_FG="\033[1;31m"
GREEN_FG="\033[1;32m"
#BLUE_FG="\033[1;34m"
MAGENTA_FG="\033[1;35m"
#CYAN_FG="\033[1;36m"
RESET="\033[0m"

# Update keystore name in .env
original_keystore=$(grep 'KEYSTORE' \
  < megazord-composition/.env | cut -d '=' -f 2)

echo -e "[*] Adding keystore name to .env"

if ! sed -i "s|${original_keystore}|${keystore}|" megazord-composition/.env; then
  echo -e "${RED_FG}[ \U2757] Error updating keystore name in .env${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Added keystore to .env${RESET}\n"

# Extract certificate for domain from keystore
echo -e "[*] Extracting ssl certificate"

if ! keytool -export -alias $domain -keystore $keystore_path \
  -storepass $password -rfc \
  -file "megazord-composition/src/secrets/cobalt.cert" 2>&1; then
  echo -e "${RED_FG} [ \U2757] Error extracting certificate from keystore${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] ${RESET}\n"

# Extract key from keystore
echo "[*] Extracting key"

if ! openssl pkcs12 -in $keystore_path -passin pass:$password \
  -nodes -nocerts \
  -out "megazord-composition/src/secrets/cobalt.key"; then
  echo -e "${RED_FG} [ \U2757] Error extracting key from keystore${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Key extracted to\
 ./megazord-composition/src/secrets/cobalt.key${RESET}\n"

# Extract certificate bundle from keystore
echo "[*] Extracting certificate bundle"

keytool -list -rfc -keystore $keystore_path \
  -storepass $password \
  > megazord-composition/src/secrets/ca_bundle.crt

echo -e "${GREEN_FG}[\U2714] Bundle extracted to\
 ./megazord-composition/src/secrets/ca-bundle.crt${RESET}\n"

# Generate new C2 profile via SourcePoint
echo "[*] Generating new c2 profile with SourcePoint"

# Generate psuedo-random number between 1-10 to pick a
# SourcePoint profile option randomly from the set (5, 7)
profile_string=$(($(shuf -i 1-10 -n 1) <= 5 ? 5 : 7))

if ! ./SourcePoint/SourcePoint -Host "$cloudfront_domain" \
  -Outfile "/opt/cobaltstrike/$c2_profile" \
  -Injector NtMapViewOfSection -Stage True \
  -Password $password -Keystore $keystore -Profile $profile_string > /dev/null; then
  echo -e "${RED_FG}[ \U2757] Error generating c2 profile${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] C2 Profile generated at\
 /opt/cobaltstrike/${c2_profile}${RESET}\n"

# Update C2_PROFILE variable in .env file
echo "[*] Adding c2 profile name to .env"

original_profile=$(grep 'C2_PROFILE' \
  < megazord-composition/.env | cut -d '=' -f 2)

# replace original profile name in .env with new profile name
if ! sed -i "s|${original_profile}|${c2_profile}|" megazord-composition/.env; then
  echo -e "${RED_FG}[ \U2757] Error adding new c2 profile name to .env${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Added c2 profile name to .env${RESET}\n"

# Generate new .htaccess based on fresh C2 Profile
echo "[*] Generating .htaccess based on c2_profile"

if ! python3 cs2modrewrite/cs2modrewrite.py \
  -i "/opt/cobaltstrike/$c2_profile" -c "https://172.19.0.5" \
  -r "https://$redirect_location" \
  -o megazord-composition/src/apache2/.htaccess; then
  echo -e "${RED_FG}[ \U2757] Error generating .htaccess${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] .htaccess generated at\
 ./megazord-composition/src/apache2/.htaccess${RESET}\n"

# Generate pseudo-random string to use as directory for payload hosting
echo "[*] Renaming uploads directory with pseudo-random string"
endpoint="/$(openssl rand -hex 6)/panda"
new_line="Alias ${endpoint} \"/var/www/uploads\""

uploads=$(grep 'Alias' \
  < megazord-composition/src/apache2/apache2.conf)

sed -i "s|${uploads}|${new_line}|" \
  megazord-composition/src/apache2/apache2.conf
echo -e "${GREEN_FG}[\U2714] Payload endpoint updated to:\
 ${MAGENTA_FG}${endpoint}${RESET}\n"

echo -e "Payloads hosted at:"
echo -e "${MAGENTA_FG}https://${cloudfront_domain}${endpoint}/NAME_OF_PAYLOAD${RESET}"
echo -e "\nPayload also accessible at https://${domain}${endpoint}/NAME_OF_PAYLOAD"

# Update PAYLOAD_DIR variable in .env with updated payload directory
original_dir=$(grep 'PAYLOAD_DIR' \
  < megazord-composition/.env | cut -d '=' -f 2)

if ! sed -i "s|${original_dir}|${endpoint}|" megazord-composition/.env; then
  echo -e "${RED_FG}[ \U2757] Error adding new payload directory name to .env${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Updated PAYLOAD_DIR in .env to new directory name${RESET}\n"
