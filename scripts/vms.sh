#!/usr/bin/env bash
# Stop paying for compute between work sessions (instruction 7).
#   ./scripts/vms.sh stop     -> deallocate all VMs (billing for CPU stops)
#   ./scripts/vms.sh start    -> start them again
#   ./scripts/vms.sh status
set -euo pipefail
RG="9969-RG"
IDS=$(az vm list -g "$RG" --query "[].id" -o tsv)
[ -z "$IDS" ] && { echo "No VMs in $RG"; exit 0; }
case "${1:-status}" in
  stop)   az vm deallocate --ids $IDS --no-wait && echo "Deallocating..." ;;
  start)  az vm start --ids $IDS --no-wait && echo "Starting..." ;;
  status) az vm list -g "$RG" -d --query "[].{VM:name, State:powerState}" -o table ;;
  *) echo "use: stop | start | status"; exit 1 ;;
esac
# The PostgreSQL server bills too - stop it with:
#   az postgres flexible-server stop -g $RG -n 9969-pgsql-ccgc5502
