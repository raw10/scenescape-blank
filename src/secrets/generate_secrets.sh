#!/bin/bash

# Copyright (C) 2025 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.

AUTHFILES=$(echo $MQTTUSERS | sed -e 's/=[^ ]*//g')
CERTDOMAIN="scenescape.intel.com"
CERTPASS=$(openssl rand -base64 33)
DBPASS=${DBPASS:-"'$(openssl rand -base64 12)'"}
EXEC_PATH="$(dirname "$(readlink -f "$0")")"
MQTTUSERS="controller.auth=scenectrl browser.auth=webuser"
SECRETSDIR="$EXEC_PATH/../secrets"

# Generate root CA key and certificate
if [ ! -f "$SECRETSDIR/ca/scenescape-ca.key" ]; then
    echo "Generating root CA key"
    mkdir -p $SECRETSDIR/ca
    openssl ecparam -name secp384r1 -genkey | openssl ec -aes256 -passout pass:$CERTPASS \
        -out $SECRETSDIR/ca/scenescape-ca.key
else
    echo "Root CA key already exists, skipping."
fi

if [ ! -f "$SECRETSDIR/certs/scenescape-ca.pem" ]; then
    echo "Generating root CA certificate"
    mkdir -p $SECRETSDIR/certs
    openssl req -passin pass:$CERTPASS -x509 -new -key $SECRETSDIR/ca/scenescape-ca.key -days 1825 \
        -out $SECRETSDIR/certs/scenescape-ca.pem -subj "/CN=ca.$CERTDOMAIN"
else
    echo "Root CA certificate already exists, skipping."
fi

# Generate web key and certificate
if [ ! -f "$SECRETSDIR/certs/scenescape-web.key" ]; then
    echo "Generating web.key"
    openssl ecparam -name secp384r1 -genkey -noout -out $SECRETSDIR/certs/scenescape-web.key
else
    echo "Web key already exists, skipping."
fi

if [ ! -f "$SECRETSDIR/certs/scenescape-web.crt" ]; then
    echo "Generating web certificate"
    openssl req -new -out $SECRETSDIR/certs/scenescape-web.csr -key $SECRETSDIR/certs/scenescape-web.key \
        -config <(sed -e "s/##CN##/web.$CERTDOMAIN/" -e "s/##SAN##/DNS.1=web.$CERTDOMAIN/" \
        -e "s/##KEYUSAGE##/serverAuth/" $EXEC_PATH/openssl.cnf)
    openssl x509 -passin pass:$CERTPASS -req -in $SECRETSDIR/certs/scenescape-web.csr \
        -CA $SECRETSDIR/certs/scenescape-ca.pem -CAkey $SECRETSDIR/ca/scenescape-ca.key -CAcreateserial \
        -out $SECRETSDIR/certs/scenescape-web.crt -days 360 -extensions x509_ext -extfile \
        <(sed -e "s/##SAN##/DNS.1=web.$CERTDOMAIN/" -e "s/##KEYUSAGE##/serverAuth/" $EXEC_PATH/openssl.cnf)
else
    echo "Web certificate already exists, skipping."
fi

# Generate broker key and certificate
if [ ! -f "$SECRETSDIR/certs/scenescape-broker.key" ]; then
    echo "Generating broker.key"
    openssl ecparam -name secp384r1 -genkey -noout -out $SECRETSDIR/certs/scenescape-broker.key
else
    echo "Broker key already exists, skipping."
fi

if [ ! -f "$SECRETSDIR/certs/scenescape-broker.crt" ]; then
    echo "Generating broker certificate"
    openssl req -new -out $SECRETSDIR/certs/scenescape-broker.csr -key $SECRETSDIR/certs/scenescape-broker.key \
        -config <(sed -e "s/##CN##/broker.$CERTDOMAIN/" -e "s/##SAN##/DNS.1=broker.$CERTDOMAIN/" \
        -e "s/##KEYUSAGE##/serverAuth/" $EXEC_PATH/openssl.cnf)
    openssl x509 -passin pass:$CERTPASS -req -in $SECRETSDIR/certs/scenescape-broker.csr \
        -CA $SECRETSDIR/certs/scenescape-ca.pem -CAkey $SECRETSDIR/ca/scenescape-ca.key -CAcreateserial \
        -out $SECRETSDIR/certs/scenescape-broker.crt -days 360 -extensions x509_ext -extfile \
        <(sed -e "s/##SAN##/DNS.1=broker.$CERTDOMAIN/" -e "s/##KEYUSAGE##/serverAuth/" $EXEC_PATH/openssl.cnf)
else
    echo "Broker certificate already exists, skipping."
fi

# Generate Django secrets
if [ ! -f "$SECRETSDIR/django/secrets.py" ]; then
    echo "Generating Django secrets"
    mkdir -p $SECRETSDIR/django
    echo -n SECRET_KEY= > $SECRETSDIR/django/secrets.py
    python3 -c 'import secrets; print("\x27" + "".join([secrets.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)]) + "\x27")' >> $SECRETSDIR/django/secrets.py
    echo "DATABASE_PASSWORD=$DBPASS" >> $SECRETSDIR/django/secrets.py
else
    echo "Django secrets already exist, skipping."
fi

# Generate auth files
for uid in $MQTTUSERS; do
    JSONFILE=${uid%=*}
    if [ ! -f "$SECRETSDIR/$JSONFILE" ]; then
        USERPASS=${uid##*=}
        case $USERPASS in
            *:* ) ;;
            * ) USERPASS=$USERPASS:$(openssl rand -base64 12);;
        esac
        USER=${USERPASS%:*}
        PASS=${USERPASS##*:}
        echo '{"user": "'$USER'", "password": "'$PASS'"}' > $SECRETSDIR/$JSONFILE
        echo "Generated $SECRETSDIR/$JSONFILE"
    else
        echo "Auth file $SECRETSDIR/$JSONFILE already exists, skipping."
    fi
done

# Generate SUPASS
if [ ! -f "$SECRETSDIR/supass" ]; then
    while true; do
        read -s -p "Enter a password for the web login 'admin' user: " SUPASS1
        echo
        read -s -p "Confirm the password: " SUPASS2
        echo
        if [ "$SUPASS1" = "$SUPASS2" ]; then
            SUPASS="$SUPASS1"
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
    echo -n "$SUPASS" > $SECRETSDIR/supass
    echo "Generated $SECRETSDIR/supass"
else
    echo "SUPASS already exists, skipping."
fi