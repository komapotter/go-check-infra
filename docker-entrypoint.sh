#!/bin/bash

set -e

SECRETS_MANAGER_ID=${SECRETS_MANAGER_ID:-}
echo ${SECRETS_MANAGER_ID}

if [ -n "$SECRETS_MANAGER_ID" ]; then
    secrets=$(aws secretsmanager get-secret-value --secret-id ${SECRETS_MANAGER_ID} |jq .SecretString |jq fromjson)
    export DBHOST=$(echo $secrets |jq -r .DBHOST)
    export DBPORT=$(echo $secrets |jq -r .DBPORT)
    export DBUSER=$(echo $secrets |jq -r .DBUSER)
    export DBPASS=$(echo $secrets |jq -r .DBPASS)
    export DBNAME=$(echo $secrets |jq -r .DBNAME)
fi

exec "$@"
