#! /bin/bash

C2_IP=$1
C2_PASSWORD=$2
C2_PROFILE=$3
KILLDATE=$4

cd /opt/cobaltstrike || exit

(sleep 10 && \
  ./agscript 172.19.0.5 50050 Alpha_5 "${C2_PASSWORD}" cnas/megazord.cna) &

echo "Teamserver starting...";

./teamserver "${C2_IP}" "${C2_PASSWORD}" "${C2_PROFILE}" "${KILLDATE}"
