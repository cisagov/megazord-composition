#!/bin/bash

function usage {
  echo -e "Megazord setup script\n"
  echo "This script will perform setup tasks to initialize the environment\
prior to launching Megazord."
  echo -e "\nThese tasks include:"
  echo "    - Setting values in the .env file used by Docker Compose"
  echo "    - Generating a pseudorandom string for the uploads directory"
  echo "    - Extracting certificates and private key from the keystore"
  echo "    - Generating a fresh C2 Profile and outputting it in the correct location"
  echo "    - Generating a .htaccess config file for Apache and outputing it in the correct location"
  echo "    - Generating a fresh Corefile and outputting it in the correct location"
  echo
  echo "Options:"
  echo "    -c    The CloudFront URL"
  echo "    -d    The domain of the teamserver"
  echo "    -p    The password for the teamserver"
  echo "    -r    The URL Apache will redirect out-of-scope traffic to"
  echo
  echo "Usage:"
  echo "    ${0##*/} -r redirect-url.com -d c2domain.com -c cloudfront.domain.net -p c2_password"
}

# Unset variables in case this script is being run a second time
unset -v redirect_location
unset -v domain
unset -v cloudfront_domain
unset -v c2_password

# Ensure the following variables are the correct paths
#########################################################################

# Path to the megazord-composition directory
megazord_path="/tools/megazord-composition/"

# Path to SourcePoint
sourcepoint_path="/tools/SourcePoint/"

# Path to cs2modrewrite
cs2mod_path="/tools/cs2modrewrite/"

# Path to Cobalt Strike
cs_path="/opt/cobaltstrike/"

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

#### Utility functions ####
check_variable() {
  # Check if a variable is set or not
  # Parameters:
  #   $1 - variable to check
  #   $2 - flag from command-line arguments responsible for this variable

  if [[ -z "${1}" ]]; then
    echo -e "${RED_FG}[!]${RESET} ${2} option is required" >&2
    usage
    exit 1
  fi
}

find_and_replace() {
  # Search a file for a target value and replaces it with
  # the updated value
  # Parameters:
  #   $1 - target string
  #   $2 - new value
  #   $3 - path to file

  # Get the original line
  original_val=$(grep "$1" "$3")

  echo "[*] Updating ${1} variable in ${3}"

  if ! sed -i "s|${original_val}|${1}=${2}|" "${3}"; then
    echo -e "${RED_FG}[!] Error updating ${1} in ${3}${RESET}"
    exit 1
  fi

  echo -e "${GREEN_FG}[\U2714] Added ${1} to ${3}${RESET}\n"
}

# Get command-line arguments
while getopts "r:d:c:hp:" arg; do
  case ${arg} in
    h)
      usage
      exit
      ;;
    c)
      cloudfront_domain=${OPTARG}
      ;;
    d)
      domain=${OPTARG}
      ;;
    p)
      c2_password=${OPTARG}
      ;;
    r)
      redirect_location=${OPTARG}
      ;;
    :)
      echo -e "${RED_FG}[!]${RESET} $0: A value is required for -${OPTARG}" >&2
      usage
      exit 1
      ;;
    ?)
      echo -e "${RED_FG}[!]${RESET} $0: Invalid option: -${OPTARG}" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$#" -eq 0 ]]; then
  echo -e "${RED_FG}[!]${RESET} Invalid number of arguments" >&2
  usage
  exit 1
fi

check_variable "${cloudfront_domain}" "-c"

check_variable "${domain}" "-d"

check_variable "${c2_password}" "-p"

check_variable "${redirect_location}" "-r"

#### Set required variables based on command-line arguments
keystore_password=$(tail -4 $original_profile | grep 'password' | cut -d ' ' -f 5)
keystore_password=${keystore_password:1:-2}
keystore="${domain}.store"
keystore_path="/tools/Malleable-C2-Profiles/normal/${keystore}"
c2_profile="${domain}-$(date '+%Y-%m-%d').profile"
########################################

# Update the CLOUDFRONT_DOMAIN in the .env file
find_and_replace "CLOUDFRONT_DOMAIN" "$cloudfront_domain" "${megazord_path}/.env"

# Update the C2_DOMAIN in the .env file
find_and_replace "C2_DOMAIN" "${domain}" "${megazord_path}/.env"

# Update the KEYSTORE in the .env file
find_and_replace "KEYSTORE" "${keystore}" "${megazord_path}/.env"

# Update the C2_PASSWORD in the .env file
find_and_replace "C2_PASSWORD" "${c2_password}" "${megazord_path}/.env"

# Extract certificate for domain from keystore
echo -e "[*] Extracting ssl certificate"

if ! res=$(keytool -export -alias "$domain" -keystore "$keystore_path" \
  -storepass "$keystore_password" -rfc \
  -file "${megazord_path}/src/secrets/cobalt.cert" 2>&1); then
  echo -e "${RED_FG} [ \U2757] $res${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] $res${RESET}\n"

# Extract key from keystore
echo "[*] Extracting key"

if ! openssl pkcs12 -in "$keystore_path" -passin pass:"$keystore_password" \
  -nodes -nocerts \
  -out "${megazord_path}/src/secrets/cobalt.key"; then
  echo -e "${RED_FG} [ \U2757] Error extracting key from keystore${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] Key extracted to\
 ${megazord_path}/src/secrets/cobalt.key${RESET}\n"

# Extract certificate bundle from keystore
echo "[*] Extracting certificate bundle"

keytool -list -rfc -keystore "$keystore_path" \
  -storepass "$keystore_password" \
  > "${megazord_path}/src/secrets/ca_bundle.crt"

echo -e "${GREEN_FG}[\U2714] Bundle extracted to\
 ${megazord_path}/src/secrets/ca-bundle.crt${RESET}\n"

# Copy keystore into the Cobalt Strike directory
echo -e "[*] Copying the keystore into ${cs_path}"
cp "$keystore_path" "${cs_path}/${keystore}"
echo -e "${GREEN_FG}[\U2714] Keystore copied into ${cs_path}${RESET}\n"

# Generate new C2 profile via SourcePoint
echo "[*] Generating new c2 profile with SourcePoint"

# Generate psuedo-random number between 1-10 to pick a
# SourcePoint profile option randomly from the set (5, 7)
profile_string=$(($(shuf -i 1-10 -n 1) <= 5 ? 5 : 7))

if ! "${sourcepoint_path}"/SourcePoint -Host "$cloudfront_domain" \
  -Outfile "${cs_path}/${c2_profile}" \
  -Injector NtMapViewOfSection -Stage True \
  -Password "$keystore_password" -Keystore "$keystore" \
  -Profile $profile_string > /dev/null; then
  echo -e "${RED_FG}[ \U2757] Error generating c2 profile${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] C2 Profile generated at\
 ${cs_path}/${c2_profile}${RESET}\n"

# Update the C2_PROFILE in the .env file
find_and_replace "C2_PROFILE" "${c2_profile}" "${megazord_path}/.env"

# Generate new .htaccess based on fresh C2 Profile
echo "[*] Generating .htaccess based on c2_profile"

if ! python3 "${cs2mod_path}"/cs2modrewrite.py \
  -i "${cs_path}/$(c2_profile)" -c "https://172.19.0.5" \
  -r "https://$redirect_location" \
  -o "${megazord_path}/src/apache2/.htaccess"; then
  echo -e "${RED_FG}[ \U2757] Error generating .htaccess${RESET}"
  exit 1
fi

echo -e "${GREEN_FG}[\U2714] .htaccess generated at\
 ${megazord_path}/src/apache2/.htaccess${RESET}\n"

# Create new Corefile for Coredns configuration
echo -e "[*] Creating Corefile using $domain in\
 ${megazord_path}/src/coredns/config"

cat > "${megazord_path}/src/coredns/config/Corefile" << CORE_BLOCK

.:53 {
	forward . 8.8.8.8
}
"$domain" {
	forward . 172.19.0.5:53
}
CORE_BLOCK

echo -e "${GREEN_FG}[\U2714] Corefile created at\
${megazord_path}/src/coredns/config/Corefile${RESET}\n"

# Generate pseudorandom string to use as directory for payload hosting
echo "[*] Renaming uploads directory with pseudorandom string"

endpoint="/$(openssl rand -hex 6)/$(openssl rand -hex 3)"
new_line="Alias ${endpoint} \"/var/www/uploads\""

uploads=$(grep 'Alias' "${megazord_path}/src/apache2/apache2.conf")

sed -i "s|${uploads}|${new_line}|" "${megazord_path}/src/apache2/apache2.conf"

echo -e "${GREEN_FG}[\U2714] Payload endpoint updated to:\
 ${MAGENTA_FG}${endpoint}${RESET}\n"

echo -e "Payloads hosted at:"
echo -e "${MAGENTA_FG}https://${cloudfront_domain}${endpoint}/NAME_OF_PAYLOAD${RESET}"
echo -e "\nPayload also accessible at ${MAGENTA_FG}https://${domain}${endpoint}/NAME_OF_PAYLOAD${RESET}\n"

# Update the PAYLOAD_DIR in the .env file with the updated payload directory
find_and_replace "PAYLOAD_DIR" "${endpoint}" "${megazord_path}/.env"
