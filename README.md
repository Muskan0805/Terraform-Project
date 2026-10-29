# CCGC 5502 – Terraform Project (project-9969)

Azure infrastructure built from one root module and eight child modules.

```
project-9969/
├── providers.tf  backend.tf  main.tf  outputs.tf     ← root module
├── modules/
│   ├── rgroup-9969/        1 resource group
│   ├── network-9969/       VNet, subnet, NSG (4 rules), NSG↔subnet link
│   ├── common-9969/        Log Analytics, Recovery Vault, storage account
│   ├── vmlinux-9969/       3 CentOS VMs (for_each) + extensions + provisioner.tf
│   ├── vmwindows-9969/     1 Windows 2022 VM (count) in an availability set
│   ├── datadisk-9969/      4 × 10 GB disks, one attached to each VM
│   ├── loadbalancer-9969/  public LB in front of the 3 Linux VMs
│   └── database-9969/      PostgreSQL Flexible Server
└── scripts/                one-time setup + start/stop helpers
```

## How the pieces talk to each other

Modules never reach into each other directly. Each one takes inputs
(`variables.tf`) and hands back outputs (`outputs.tf`); the root `main.tf` is
the switchboard that passes one module's outputs into the next.

- `rgroup` → RG name → every other module
- `network` → subnet ID → both VM modules
- `common` → storage blob URL → both VM modules (boot diagnostics)
- `vmlinux` → NIC IDs → `loadbalancer`
- `vmlinux` + `vmwindows` → VM IDs → `datadisk`

Terraform reads those references and works out the build order by itself.

## Setup (once)

```bash
az login
./scripts/personalize.sh 1234 firstname.lastname   # your real ID digits + name
cd ../project-1234                                  # folder was renamed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""    # skip if you already have a key
./scripts/create-backend.sh                         # state storage account
```

## Every terminal session

```bash
source scripts/env.sh     # sets subscription ID + admin password
```

Do this **before** you start recording – then every command in the video runs
without prompts.

## The recorded run

```bash
whoami ; hostname ; date
terraform init
terraform validate
terraform apply --auto-approve
terraform state list | nl     # should end at 48
terraform output
```

Afterwards: `terraform destroy --auto-approve`. Between work sessions:
`./scripts/vms.sh stop`.

## Where the 48 comes from

| Module | Resources | Count |
|---|---|---|
| rgroup | resource group | 1 |
| network | vnet, subnet, NSG, NSG association | 4 |
| common | Log Analytics, Recovery Vault, storage account | 3 |
| vmlinux | (public IP, NIC, VM, 2 extensions, null_resource) × 3 | 18 |
| vmwindows | availability set, public IP, NIC, VM, antimalware ext | 5 |
| datadisk | (disk + attachment) × 4 | 8 |
| loadbalancer | public IP, LB, backend pool, 3 NIC associations, probe, rule | 8 |
| database | PostgreSQL server | 1 |
| **Total** | | **48** |

The count only works out because of two choices: the 4 NSG rules are
`dynamic` blocks *inside* the NSG (not 4 separate rule resources), and there are
no `data` blocks (those show up in `state list` too). Add either and you'd
overshoot.

## Decisions I made (instruction 6)

- **Region `canadacentral`** – closest to Toronto and has 3 availability zones.
- **VM size `Standard_B2als_v2`** – cheapest of the allowed examples, runs both
  Gen1 and Gen2 images.
- **Standard load balancer, not Basic** – Microsoft retired Basic LBs and Basic
  public IPs on 30 Sept 2025; Azure won't create them anymore. All public IPs
  are Standard for the same reason.
- **Recovery vault named `rsv-9969-vault`** – Azure requires vault names to
  start with a letter, so the ID can't come first. Same reason DNS labels
  start with `vm9969-…`.
- **Backend storage outside Terraform** – if Terraform owned the account holding
  its state, `destroy` would delete its own state mid-run.
- **Password via `TF_VAR_admin_password`** – keeps secrets out of GitHub and
  still lets `apply --auto-approve` run without prompts.
- **Subnet ID comes from the NSG association output** – so VMs aren't created
  until port 22 is open, and the SSH provisioner can connect.
- **Disks in the VM's zone** – a disk can only attach to a VM in the same zone.
- **PostgreSQL** – Burstable B1ms, 32 GB, no HA, no geo-backup = cheapest.

## If something fails

- **CentOS 8.2 image not found** – CentOS 8 went end-of-life in Dec 2021 and
  old images get pulled from Azure over time. Check first:
  `az vm image list --publisher OpenLogic --offer CentOS --sku 8_2 --all -o table`
  If it's empty, change `sku` in `modules/vmlinux-9969/variables.tf` (e.g. to an
  available `8_5`) and tell your professor why.
- **AzureMonitorLinuxAgent fails** – the agent may no longer support CentOS 8.
  Check the error message in the apply log before changing anything.
- **"Location is restricted" for PostgreSQL** – student subscriptions sometimes
  block it in a region; try `canadaeast` or `eastus` for the DB.
- **Name already taken** – storage, DNS and DB names are global; tweak the
  suffix (e.g. `ccgc5502` → `ccgc5502a`).
- **Not 48 lines** – compare `terraform state list` against the table above.
