#!/usr/bin/env bash
# Run ONCE before the first "terraform init". Creates the backend storage
# that holds terraform.tfstate. It's deliberately NOT part of the Terraform
# code, so "terraform destroy" can never delete its own state.
set -euo pipefail
ID="9969"   # personalize.sh replaces this
RG="${ID}-tfstate-RG"
SA="${ID}tfstatesa"
LOC="canadacentral"
TAGS=(Project="CCGC 5502 Terraform Project" Name="muskan" ExpirationDate="2027-12-31" Environment="Learning")

az group create -n "$RG" -l "$LOC" --tags "${TAGS[@]}" -o none
az storage account create -n "$SA" -g "$RG" -l "$LOC" \
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
  --tags "${TAGS[@]}" -o none
az storage container create -n tfstate --account-name "$SA" --auth-mode login -o none \
  || az storage container create -n tfstate --account-name "$SA" -o none
echo "Backend ready: $RG / $SA / tfstate"
