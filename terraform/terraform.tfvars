project = "my-k8s"
region  = "ap-southeast-1"

# Map local files into variables
# openssl genrsa -out sa.key 2048
# openssl rsa -in sa.key -pubout -out sa.pub
sa_private_key_path = "./keys/sa.key"
sa_public_key_path  = "./keys/sa.pub"
oidc_jwks_json_path     = "./keys/sa.jwks.json"

# placeholder for now; we'll fill after we know issuer URL
# oicd s3 url
# ISSUER_HOST="my-k8s-oidc-116981769322-ap-southeast-1.s3.ap-southeast-1.amazonaws.com" 
# openssl s_client -servername "$ISSUER_HOST" -connect "$ISSUER_HOST:443" < /dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/issuer-cert.pem
# openssl x509 -in /tmp/issuer-cert.pem -noout -fingerprint -sha1 | sed 's/://g' | cut -d'=' -f2 
# remove all ':' in the string
# oidc_thumbprint = "257753EF33DB8CA5F8A03D9D6CACAE2A9007A065"
# oidc_issuer_url = "https://my-k8s-oidc-116981769322-ap-southeast-1.s3.ap-southeast-1.amazonaws.com"

oidc_thumbprint = "257753EF33DB8CA5F8A03D9D6CACAE2A9007A065"
oidc_issuer_url = "https://my-k8s-oidc-116981769322-ap-southeast-1.s3.ap-southeast-1.amazonaws.com"
