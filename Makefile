
# Variable
REGION ?= "ap-southeast-1"
PROJECT ?= "my-k8s"
TARGET ?= "all"

OIDC_ISSUER_URL ?= ""
OIDC_ISSUER_HOST_URL ?= ""
OIDC_THUMBPRINT ?= ""

.PHONY: clean help deploy destroy oidc-deploy oidc-destroy

SHELL := /bin/bash

# Target: help
help:
	@echo "Makefile commands:"
	@echo "  make help          - Show this help message"
	@echo "  make deploy        - Deploy the application"
	@echo "  make destroy       - Destroy the deployed application"

oidc-deploy:
	@echo "Setting up OIDC provider..."
	cd terraform/oidc-s3 && terraform init && terraform apply -auto-approve

oidc-destroy:
	@echo "Destroying OIDC provider..."
	cd terraform/oidc-s3 && terraform destroy -auto-approve

deploy: oidc-deploy
	@echo "Deploying the application..."
	eval $$(bash ./get-oidc-info.sh); \
	cd terraform && terraform init && terraform apply \
		-var="oidc_issuer_url=$$OIDC_ISSUER_HOST" \
		-var="oidc_thumbprint=$$OIDC_THUMBPRINT" \
		-auto-approve

destroy: oidc-destroy
	@echo "Destroying the deployed application..."
	cd terraform && terraform destroy -auto-approve

clean-oidc:
	@echo "Cleaning up OIDC provider..."
	rm -rf terraform/oidc-s3/.terraform*
	rm -rf terraform/oidc-s3/terraform.tfstate*

clean-all:
	@echo "Cleaning up..."
	rm -rf terraform/.terraform* terraform/oidc-s3/.terraform*
	rm -rf terraform/terraform.tfstate* terraform/oidc-s3/terraform.tfstate*
