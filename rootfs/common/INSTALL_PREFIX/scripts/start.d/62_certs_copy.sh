#!/bin/sh

# In case there are no certificates, copy them
# from ${INSTALL_PREFIX}/certs folder (part of SW release)
# or from /data/certs

mkdir -p /var/certs

if [ ! -r /var/certs/ca.pem ] || \
   [ ! -r /var/certs/client.pem ] || \
   [ ! -r /var/certs/client_dec.key ]; then

    if [ -e ${INSTALL_PREFIX}/certs/client.pem ]; then
        echo "No certs found in flash, using default certs"
        cp ${INSTALL_PREFIX}/certs/ca.pem /var/certs/
        cp ${INSTALL_PREFIX}/certs/client.pem /var/certs/
        cp ${INSTALL_PREFIX}/certs/client_dec.key /var/certs/
    elif [ -e /data/certs/client.pem ]; then
        echo "No certs found in flash, using data certs"
        cp /data/certs/ca.pem /var/certs/
        cp /data/certs/client.pem /var/certs/
        cp /data/certs/client_dec.key /var/certs/
    else
        echo "ERROR: No certs found"
    fi
fi
