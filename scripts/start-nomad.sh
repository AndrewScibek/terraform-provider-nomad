#!/bin/bash

export VAULT_TEST_TOKEN=terraform-provider-nomad-token
export VAULT_ADDR=http://localhost:8200

if [ ! -e /tmp/vault-test.pid ]; then
    vault server -dev -dev-root-token-id=$VAULT_TEST_TOKEN > /dev/null 2>&1 &

    VAULT_PID=$!
    echo $VAULT_PID > /tmp/vault-test.pid
fi

if [ ! -e /tmp/nomad-test.pid ]; then
    nomad agent -dev -acl-enabled -vault-address=$VAULT_ADDR -vault-token $VAULT_TEST_TOKEN -vault-enabled -vault-allow-unauthenticated=false > /dev/null 2>&1 &
    NOMAD_PID=$!
    echo $NOMAD_PID > /tmp/nomad-test.pid

    # Give some time for the process to initialize
    sleep 5

    http --ignore-stdin POST http://localhost:4646/v1/acl/bootstrap | jq -r '.SecretID' > /tmp/nomad-test.token
    cat /tmp/nomad-test.token
elif [ -e /tmp/nomad-test.token ]; then 
  cat /tmp/nomad-test.token
fi
