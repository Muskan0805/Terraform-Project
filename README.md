# CCGC 5502 – Terraform Project (project-9969)

Azure infrastructure provisioned with Terraform: one root module and eight child modules.

**Course:** CCGC 5502 Automation · **Professor:** Asghar Ghori · **Student:** muskan (9969)

---

## Project structure

```
project-9969/
├── providers.tf      ← azurerm + null providers
├── backend.tf        ← remote state in Azure Storage
├── main.tf           ← locals (ID, region, tags, VM size) + all module calls
├── outputs.tf        ← prints everything the child modules return
└── modules/
    ├── rgroup-9969/        1 resource group
    ├── network-9969/       VNet, subnet, NSG (4 inbound rules), NSG ↔ subnet link
    ├── common-9969/        Log Analytics, Recovery Services vault, storage account
    ├── vmlinux-9969/       3 CentOS 8.2 VMs (for_each) + 2 extensions + provisioner.tf
    ├── vmwindows-9969/     1 Windows Server 2022 VM (count) in an availability set
    ├── datadisk-9969/      4 × 10 GB data disks, one attached to each VM
    ├── loadbalancer-9969/  public load balancer in front of the 3 Linux VMs
    └── database-9969/      Azure Database for PostgreSQL Flexible Server
```

Each child module follows the same pattern: `variables.tf` (inputs), `main.tf`
(resources), `outputs.tf` (values returned to the root). The Linux VM module
also has `provisioner.tf`.

---

## How the modules connect

Modules never reference each other directly. The root `main.tf` passes one
module's outputs into another module's inputs:

| From | Output | To |
|---|---|---|
| rgroup | resource group name | every other module |
| network | subnet ID | vmlinux, vmwindows |
| common | storage blob endpoint | vmlinux, vmwindows (boot diagnostics) |
| vmlinux | NIC IDs | loadbalancer |
| vmlinux + vmwindows | VM IDs | datadisk |

Terraform reads these references to build its dependency graph, so resources
are created in the correct order automatically and independent resources are
created in parallel.

---

## What each module builds

**rgroup-9969:** resource group `9969-RG`.

**network-9969:** `9969-VNET` (10.0.0.0/16), `9969-SUBNET` (10.0.1.0/24), and
`9969-NSG` with inbound allow rules for ports **22** (SSH), **3389** (RDP),
**5985** (WinRM) and **80** (HTTP). The NSG is associated with the subnet. The rules are `dynamic` blocks inside the NSG rather than separate resources.

**common-9969:** Log Analytics workspace `9969-LAW` (PerGB2018, 30-day
retention), Recovery Services vault `rsv-9969-vault` (Standard, LRS), and
storage account `9969ccgc5502sa` (Standard, LRS), which is used for VM boot
diagnostics and is separate from the backend storage account.

**vmlinux-9969:** three CentOS 8.2 VMs (`9969-linux-vm1/2/3`), one per
availability zone (1, 2, 3), created with `for_each` over a map of
`name => zone`. Each VM has a Standard static public IP with a unique DNS
label, a NIC, SSH-key login, boot diagnostics, a system-assigned managed
identity, and two extensions:
- `NetworkWatcherAgentLinux` (Microsoft.Azure.NetworkWatcher)
- `AzureMonitorLinuxAgent` (Microsoft.Azure.Monitor)

`provisioner.tf` uses a `null_resource` with a `remote-exec` provisioner to SSH into each VM and print its hostname.

**vmwindows-9969:** one Windows Server 2022 VM (`9969-win-vm1`) created with
`count`, inside availability set `9969-win-avset` (2 fault domains, 5 update
domains). It has a public IP with a unique DNS label, boot diagnostics, and the `IaaSAntimalware` extension.

**datadisk-9969:** four empty 10 GB Standard_LRS managed disks, each attached
to one VM at LUN 0. Each Linux disk is created in the same zone as its VM.

**loadbalancer-9969:** public load balancer `9969-LB` with a frontend public IP, a backend pool containing the three Linux VM NICs, a TCP health probe on port 80, and a load-balancing rule for port 80.

**database-9969:** PostgreSQL Flexible Server `9969-pgsql-ccgc5502`, version 16, Burstable `B_Standard_B1ms`, 32 GB storage, 7-day backups, no HA, no
geo-redundant backup (the cheapest configuration).

---

## Remote backend

State is stored in Azure Blob Storage, not on the local machine:

| Setting | Value |
|---|---|
| Resource group | `9969-tfstate-RG` |
| Storage account | `9969tfstatesa` |
| Container | `tfstate` |
| State file | `project-9969.tfstate` |

The backend gives **state locking** (two runs can't change state at the same
time), keeps state safe if the laptop is lost, and keeps it out of Git.

The backend storage was created **once, outside Terraform**, with the Azure CLI. If Terraform managed the account that holds its own state, `terraform destroy` would delete its own state partway through.

```bash
az group create -n 9969-tfstate-RG -l canadacentral \
  --tags Project="CCGC 5502 Terraform Project" Name="muskan" \
         ExpirationDate="2027-12-31" Environment="Learning"

az storage account create -n 9969tfstatesa -g 9969-tfstate-RG -l canadacentral \
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
  --tags Project="CCGC 5502 Terraform Project" Name="muskan" \
         ExpirationDate="2027-12-31" Environment="Learning"

az storage container create -n tfstate --account-name 9969tfstatesa --auth-mode login
```

---

## Tags

All resources get the same four tags, defined once in `locals` as
`common_tags` and passed into every module:

```hcl
Project        = "CCGC 5502 Terraform Project"
Name           = "muskan"
ExpirationDate = "2027-12-31"
Environment    = "Learning"
```

---

## Prerequisites

- Azure CLI, logged in with `az login`
- Terraform 1.5 or later
- An SSH key pair at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
  (create one with `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""`)
- A `terraform.tfvars` file in the project folder containing the admin
  password for the Windows VM and PostgreSQL server:
  ```hcl
  admin_password = "<12+ chars: upper, lower, digit, symbol>"
  ```
  This file is listed in `.gitignore` and is **never committed**.

Before running Terraform in a new terminal:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

---

## Running the project

```bash
whoami ; hostname ; date
terraform init
terraform validate
terraform apply --auto-approve
terraform state list | nl      # 48 lines
terraform output
```

When finished:

```bash
terraform destroy --auto-approve
```

---

## Resource count (48)

| Module | Resources | Count |
|---|---|---|
| rgroup | resource group | 1 |
| network | VNet, subnet, NSG, NSG association | 4 |
| common | Log Analytics, Recovery vault, storage account | 3 |
| vmlinux | (public IP, NIC, VM, 2 extensions, null_resource) × 3 | 18 |
| vmwindows | availability set, public IP, NIC, VM, antimalware extension | 5 |
| datadisk | (disk + attachment) × 4 | 8 |
| loadbalancer | public IP, LB, backend pool, 3 NIC associations, probe, rule | 8 |
| database | PostgreSQL Flexible Server | 1 |
| **Total** | | **48** |

---

## Configuration decisions and deviations from the brief

| Decision | Reason |
|---|---|
| **Region: East US** | The subscription had 0 quota for the Basv2 family, and Canada Central only offered ARM-based sizes, which cannot run x64 CentOS or Windows images. |
| **VM size: `Standard_D2as_v4`** (2 vCPU) | Basv2 quota was 0. DASv4 had a quota of 10 vCPUs (4 VMs × 2 = 8) and supports the Gen1 CentOS 8.2 image. |
| **Database in Canada Central** | No PostgreSQL Flexible Server versions were available to the subscription in East US. A resource can sit in a different region from its resource group. |
| **Standard load balancer, not Basic** | Microsoft retired Basic load balancers and Basic public IPs on 30 Sept 2025. All public IPs are Standard for the same reason. |
| **Azure Monitor agent pinned to 1.21, auto-upgrade off** | Newer agent versions report "Unsupported operating system: centos 8". With auto-upgrade on, Azure silently installs the latest 1.x. |
| **Linux VMs in availability zones** | The brief asks for separate availability zones. A VM can be in a zone or an availability set, not both. |
| **Vault and DNS names start with a letter** | Azure requires it, so the vault is `rsv-9969-vault` and DNS labels are `vm9969-…`. |
| **NSG rules as `dynamic` blocks** | Same result in Azure, kept inside the NSG resource. |
| **Subnet ID taken from the NSG association** | VMs aren't created until the NSG is attached, so port 22 is open when the provisioner connects. |
| **Password via `terraform.tfvars`** | Keeps secrets out of Git while letting `apply --auto-approve` run with no prompts. |

---

## Cost control

- Small 2-vCPU VMs, Standard HDD disks, Burstable database tier, LRS storage.
- VMs can be stopped between sessions:
  `az vm deallocate --ids $(az vm list -g 9969-RG --query "[].id" -o tsv)`
- All infrastructure is removed after evaluation with
  `terraform destroy --auto-approve`. The Terraform code stays in this repo.
