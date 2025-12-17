#!/bin/bash
# get_variables.sh

OIDC_ISSUER_HOST=""
OIDC_ISSUER_HOST_URL=""
OIDC_THUMBPRINT=""

cd terraform/oidc-s3

export OIDC_ISSUER_HOST="$(terraform output -raw oidc_issuer_url)"
OIDC_ISSUER_HOST_URL="$(terraform output -raw oidc_issuer_url | sed 's|https://||')"

openssl s_client -servername "$OIDC_ISSUER_HOST_URL" -connect "$OIDC_ISSUER_HOST_URL:443" < /dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/issuer-cert.pem
export OIDC_THUMBPRINT="$(openssl x509 -in /tmp/issuer-cert.pem -noout -fingerprint -sha1 | sed 's/://g' | cut -d'=' -f2)"

echo "OIDC_ISSUER_HOST=$OIDC_ISSUER_HOST"
echo "OIDC_THUMBPRINT=$OIDC_THUMBPRINT"
