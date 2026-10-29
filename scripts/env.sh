# Load into your shell BEFORE running terraform (every new terminal):
#   source scripts/env.sh
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
if [ -z "${TF_VAR_admin_password:-}" ]; then
  read -rsp "Admin password for Windows VM + PostgreSQL (12+ chars, upper, lower, digit, symbol): " TF_VAR_admin_password; echo
  export TF_VAR_admin_password
fi
echo "Subscription: $ARM_SUBSCRIPTION_ID - password set."
