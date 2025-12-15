
# Variable
REGION ?= ap-southeast-1
PROJECT ?= my-k8s
TARGET ?= all

OIDC_ISSUER_URL ?= ""

.PHONY: clean help deploy destroy oidc-deploy oidc-destroy

# Target: help
help:
	@echo "Makefile commands:"
	@echo "  make help          - Show this help message"
	@echo "  make deploy        - Deploy the application"
	@echo "  make destroy       - Destroy the deployed application"

oidc-deploy:
	@echo "Setting up OIDC provider..."
	cd terraform/oidc-s3 && terraform init && terraform apply -auto-approve && \
		OIDC_ISSUER_URL=$$(terraform output -raw oidc_issuer_url) && \
		OIDC_ISSUER_HOST_URL=$$(echo $$OIDC_ISSUER_URL | sed 's|https://||') && \

oidc-destroy:
	@echo "Destroying OIDC provider..."
	cd terraform/oidc-s3 && terraform destroy -auto-approve

deploy: oidc-deploy
	@echo "Deploying the application..."
	cd terraform && terraform init && terraform apply -auto-approve

destroy: oidc-destroy
	@echo "Destroying the deployed application..."
	cd terraform && terraform destroy -auto-approve

clean-oidc:
	@echo "Cleaning up OIDC provider..."
	rm -rf terraform/oidc-s3/.terraform
	rm -f terraform/oidc-s3/terraform.tfstate terraform/oidc-s3/terraform.tfstate.backup
	rm -f terraform/oidc-s3/.terraform.lock.hcl

clean-all:
	@echo "Cleaning up..."
	rm -rf terraform/.terraform terraform/oidc-s3/.terraform
	rm -f terraform/terraform.tfstate terraform/terraform.tfstate.backup
	rm -f terraform/oidc-s3/terraform.tfstate terraform/oidc-s3/terraform.tfstate.backup
	rm -f terraform/oidc-s3/.terraform.lock.hcl
	rm -f terraform/.terraform.lock.hcl
