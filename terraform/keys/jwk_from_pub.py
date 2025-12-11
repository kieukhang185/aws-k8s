from jwcrypto import jwk
import argparse
import json
# Load public key from PEM file

argparse = argparse.ArgumentParser(description="Convert PEM public key to JWK")
argparse.add_argument("--pem_file", help="Path to the PEM public key file", default="sa.pub", nargs='?')
args = argparse.parse_args()

with open(args.pem_file, "rb") as pem_file:
   pub_key_data = pem_file.read()

# Create JWK object
key = jwk.JWK.from_pem(pub_key_data)

# Export as JWKS (JSON Web Key Set)
jwks = {"keys": [key.export(as_dict=True)]}
jwks_json = "sa.jwks.json"

with open(jwks_json, "w") as jwks_file:
   jwks_file.write(json.dumps(jwks))
