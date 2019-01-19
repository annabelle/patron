#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This installer must be run as root."
    echo "Use the command 'sudo su -' (include the trailing hypen) and try again"
    exit 1
fi

host=$1
email=$2
key=$(hexdump -n 24 -e '4/4 "%08X"' /dev/urandom)
file="opt-librepatron.custom.yml"

wget https://raw.githubusercontent.com/JeffVandrewJr/patron/master/opt-librepatron.template.yml
cat opt-librepatron.template.yml > $file
rm opt-librepatron.template.yml

sed -i "s/<host>/$host/g" $file
sed -i "s/<email>/$email/g" $file
sed -i "s/<key>/$key/g" $file

mv $file /root/btcpayserver-docker/docker-compose-generator/docker-fragments

if [ echo $BTCPAYGEN_ADDITIONAL_FRAGMENTS | grep -q "optlibrepatron.custom.yml" ]; then
    echo "BTCPAYGEN_ADDITIONAL_FRAGMENTS is already properly set."
elif [ -z ${BTCPAYGEN_ADDITIONAL_FRAGMENTS+x} ]; then
    export BTCPAYGEN_ADDITIONAL_FRAGMENTS="opt-librepatron.custom.yml"
else
    export BTCPAYGEN_ADDITIONAL_FRAGMENTS=${BTCPAYGEN_ADDITIONAL_FRAGMENTS};opt-librepatron.custom.yml
fi

cd /root/btcpayserver-docker

. ./btcpay-setup.sh -i