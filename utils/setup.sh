#!/bin/bash


function usage {
    echo -e "Megazord setup script\n"
    echo "This script will perform setup tasks to initialize the environment\ 
prior to launching megazord." 
    echo -e "\nThese tasks include:"
    echo "    - Setting values in the .env file used by docker compose"
    echo "    - Generating a pseudorandom string for the uploads directory"
    echo "    - Extracting certificates and private key from the keystore" 
    echo "    - Generating a fresh C2 Profile and outputting it in the correct location"
    echo "    - Generating an htaccess config file for Apache and outputing it in the correct location"
    echo "    - Generating a fresh Corefile and outputting it in the correct location"
    echo
    echo "Options:"
    echo "    -r    The url Apache will redirect out-of-scope traffic to"
    echo "    -d    The domain of the teamserver"
    echo "    -c    The cloudfront url"
    echo
    echo "Usage:"
    echo "    ./setup.sh -r redirect-url.com -d c2domain.com -c cloudfront.domain.net"
}

# unset variables in case this script is being ran a 2nd time
unset -v redirect_location
unset -v domain
unset -v cloudfront_domain

# Ensure the following variable is the correct path
#########################################################################

# Path to amazon.profile or ocsp.profile containing keystore information
original_profile="/tools/Malleable-C2-Profiles/normal/amazon.profile"

#########################################################################


# COLORS
RED_FG="\033[1;31m"
GREEN_FG="\033[1;32m"
#BLUE_FG="\033[1;34m"
MAGENTA_FG="\033[1;35m"
#CYAN_FG="\033[1;36m"
RESET="\033[0m"

#### END variables ####


while getopts "r:d:c:h:" arg; do
    case ${arg} in
        h)
            usage
            exit;;
        r)
            redirect_location=${OPTARG};;
        d)
            domain=${OPTARG};;
        c)
            cloudfront_domain=${OPTARG};;
        :)
            echo -e "${RED_FG}[!]${RESET} $0: A value is required for -${OPTARG}" >&2
            exit 1;;
        ?)
            echo -e "${RED_FG}[!]${RESET} $0: Invalid option: -${OPTARG}" >&2
            exit 2;;
    esac
done

if [ -z "${redirect_location}" ]; then
    echo -e "${RED_FG}[!]${RESET}-r option is required" >&2
    exit 1
fi

if [ -z "${domain}" ]; then
    echo -e "${RED_FG}[!]${RESET}-d option is required" >&2
    exit 1
fi

if [ -z "${cloudfront_domain}" ]; then
    echo -e "${RED_FG}[!]${RESET}-c option is required" >&2
    exit 1
fi


# DO NOT modify the following variables
keystore_password=$(tail -4 $original_profile | grep 'password' | cut -d ' ' -f 5)
keystore_password=${keystore_password:1:-2}
keystore="${domain}.store"
keystore_path="/tools/Malleable-C2-Profiles/normal/${keystore}"
c2_profile="${domain}-$(date '+%Y-%m-%d').profile"
########################################


find_and_replace () 
{
    original_val=$(grep $1 $3)
    echo "[*] Updating ${1} variable in ${3}"

    if ! sed -i "s|${original_val}|${1}=${2}|" ${3}; then
        echo -e "${RED_FG}[ \U2757] Error updating ${1} in ${3}${RESET}"
        exit 1
    fi

    echo -e "${GREEN_FG}[\U2714] Added ${1} to ${3}${RESET}\n"
}


# Add cloudfront_domain to env file
find_and_replace "CLOUDFRONT_DOMAIN" $cloudfront_domain "/tools/megazord-composition/.env"

# Add c2_domain to env file
find_and_replace "C2_DOMAIN" ${domain} "/tools/megazord-composition/.env"

# Update keystore name in .env
find_and_replace "KEYSTORE" ${keystore} "/tools/megazord-composition/.env"


# Extract certificate for domain from keystore
echo -e "[*] Extracting ssl certificate"

if ! res=$(keytool -export -alias $domain -keystore $keystore_path \
  -storepass $keystore_password -rfc \
  -file "/tools/megazord-composition/src/secrets/cobalt.cert" 2>&1); then
  echo -e "${RED_FG} [ \U2757] $res${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] $res${RESET}\n"

# Extract key from keystore
echo "[*] Extracting key"

if ! openssl pkcs12 -in $keystore_path -passin pass:$keystore_password \
  -nodes -nocerts \
  -out "/tools/megazord-composition/src/secrets/cobalt.key"; then
  echo -e "${RED_FG} [ \U2757] Error extracting key from keystore${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Key extracted to\
 /tools/megazord-composition/src/secrets/cobalt.key${RESET}\n"

# Extract certificate bundle from keystore
echo "[*] Extracting certificate bundle"

keytool -list -rfc -keystore $keystore_path \
  -storepass $keystore_password \
  > /tools/megazord-composition/src/secrets/ca_bundle.crt

echo -e "${GREEN_FG}[\U2714] Bundle extracted to\
 /tools/megazord-composition/src/secrets/ca-bundle.crt${RESET}\n"

# Copy keystore into cobaltstrike directory
echo -e "[*] Copying the keystore into /opt/cobaltstrike"
cp $keystore_path /opt/cobaltstrike/$keystore
echo -e "${GREEN_FG}[\U2714] Keystore copied into /opt/cobaltstrike${RESET}\n"

# Generate new C2 profile via SourcePoint
echo "[*] Generating new c2 profile with SourcePoint"

# Generate psuedo-random number between 1-10 to pick a
# SourcePoint profile option randomly from the set (5, 7)
profile_string=$(($(shuf -i 1-10 -n 1) <= 5 ? 5 : 7))

if ! /tools/SourcePoint/SourcePoint -Host "$cloudfront_domain" \
  -Outfile "/opt/cobaltstrike/$c2_profile" \
  -Injector NtMapViewOfSection -Stage True \
  -Password $keystore_password -Keystore $keystore \
  -Profile $profile_string > /dev/null; then
  echo -e "${RED_FG}[ \U2757] Error generating c2 profile${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] C2 Profile generated at\
 /opt/cobaltstrike/${c2_profile}${RESET}\n"

# Update C2_PROFILE variable in .env file
find_and_replace "C2_PROFILE" ${c2_profile} "/tools/megazord-composition/.env"

# Generate new .htaccess based on fresh C2 Profile
echo "[*] Generating .htaccess based on c2_profile"

if ! python3 /tools/cs2modrewrite/cs2modrewrite.py \
  -i "/opt/cobaltstrike/$c2_profile" -c "https://172.19.0.5" \
  -r "https://$redirect_location" \
  -o /tools/megazord-composition/src/apache2/.htaccess; then
  echo -e "${RED_FG}[ \U2757] Error generating .htaccess${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] .htaccess generated at\
 /tools/megazord-composition/src/apache2/.htaccess${RESET}\n"

# Create new Corefile for Coredns configuration
echo -e "[*] Creating Corefile using $domain in\
 /tools/megazord-composition/src/coredns/config"

cat > /tools/megazord-composition/src/coredns/config/Corefile << CORE_BLOCK

.:53 {
	forward . 8.8.8.8
}
"$domain" {
	forward . 172.19.0.5:53
}
CORE_BLOCK

echo -e "${GREEN_FG}[\U2714] Corefile created at\
/tools/megazord-composition/src/coredns/config/Corefile${RESET}\n"

# Generate pseudo-random string to use as directory for payload hosting
echo "[*] Renaming uploads directory with pseudo-random string"

endpoint="/$(openssl rand -hex 6)/$(openssl rand -hex 3)"
new_line="Alias ${endpoint} \"/var/www/uploads\""

uploads=$(grep 'Alias' \
  < /tools/megazord-composition/src/apache2/apache2.conf)

sed -i "s|${uploads}|${new_line}|" \
  /tools/megazord-composition/src/apache2/apache2.conf

echo -e "${GREEN_FG}[\U2714] Payload endpoint updated to:\
 ${MAGENTA_FG}${endpoint}${RESET}\n"

echo -e "Payloads hosted at:"
echo -e "${MAGENTA_FG}https://${cloudfront_domain}${endpoint}/NAME_OF_PAYLOAD${RESET}"
echo -e "\nPayload also accessible at ${MAGENTA_FG}https://${domain}${endpoint}/NAME_OF_PAYLOAD${RESET}\n"

# Update PAYLOAD_DIR variable in .env with updated payload directory
find_and_replace "PAYLOAD_DIR" ${endpoint} "/tools/megazord-composition/.env"

