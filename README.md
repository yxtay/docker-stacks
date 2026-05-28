# docker-stacks

Automations with docker stacks

## Scaffolding

This project uses several tools to ensure code quality and consistency:

- **MegaLinter**: Runs in GitHub Actions to perform comprehensive linting on
  every Pull Request.
- **Pre-commit**: Local git hooks to format and lint code before committing.
- **Renovate**: Automatically manages and updates dependencies.
- **EditorConfig**: Ensures consistent coding styles across different editors
  and IDEs.
- **Yamlfmt**: Specifically handles YAML file formatting.
- **GitHub Actions**: Workflows for CI, security scans (OSSF Scorecard,
  Semgrep, etc.), and automerge.

## OCI Resource Manager — ARM Free Tier VPS

The `oci-rm/` directory contains a Terraform stack for OCI Resource Manager that
provisions an Ampere A1 (ARM) Always Free VPS, including VCN, subnet, internet
gateway, security rules, and compute instance.

### Always Free limits

| Resource | Limit |
|---|---|
| Shape | `VM.Standard.A1.Flex` |
| OCPUs | 4 total across all A1 instances |
| Memory | 24 GB total across all A1 instances |
| Block storage | 200 GB total |

Defaults: 2 OCPU / 12 GB RAM / 50 GB boot volume.

### Variables

All variables have sensible defaults. Required inputs:

- **Compartment** — target OCI compartment
- **SSH Public Key** — key for instance access
- **Cloud-init Script** (optional) — paste `scripts/init.sh` to auto-install Dokploy

### Deploy via OCI Console (recommended)

1. Zip the stack:

    ```bash
    cd oci-rm && zip -r ../oci-rm-stack.zip . && cd ..
    ```

2. Open **Developer Services → Resource Manager → Stacks** in the OCI Console.
3. Click **Create Stack** → **Upload a .zip file** → select `oci-rm-stack.zip`.
4. Fill in the form (variables pre-populated with defaults).
5. Click **Apply**.

### Deploy via OCI CLI

```bash
# Create stack
oci resource-manager stack create \
  --compartment-id <compartment-ocid> \
  --config-source oci-rm-stack.zip \
  --display-name "arm-free-tier" \
  --variables '{"ssh_public_key":"<your-key>"}'

# Apply stack (auto-approved)
oci resource-manager job create-apply-job \
  --stack-id <stack-ocid> \
  --execution-plan-strategy AUTO_APPROVED

# Poll job status
oci resource-manager job get --job-id <job-ocid>

# Get outputs after apply
oci resource-manager job get-job-tf-state --job-id <job-ocid> --file -
```

### Deploy via local Terraform

Requires OCI CLI configured (`oci setup config`) and Terraform installed.

```bash
cd oci-rm
terraform init
terraform plan \
  -var tenancy_ocid=<tenancy-ocid> \
  -var compartment_ocid=<compartment-ocid> \
  -var region=<region> \
  -var ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
terraform apply
```

Or create a `terraform.tfvars` file:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..<hash>"
compartment_ocid = "ocid1.compartment.oc1..<hash>"
region           = "ap-singapore-1"
ssh_public_key   = "ssh-ed25519 AAAA..."
```

### Destroy

```bash
# Via CLI
oci resource-manager job create-destroy-job \
  --stack-id <stack-ocid> \
  --execution-plan-strategy AUTO_APPROVED

# Via local Terraform
terraform destroy
```

## Dokploy Setup on OCI

This repository includes a script to automate the setup of Dokploy on an Oracle
Cloud Infrastructure (OCI) Ubuntu instance.

### Initialization Script

The `scripts/init.sh` script performs the following actions:

1. Updates and upgrades system packages.
2. Configures `iptables` to allow traffic on essential ports:
    - **80 (TCP)**: HTTP traffic.
    - **443 (TCP/UDP)**: HTTPS traffic.
    - **3000 (TCP)**: Dokploy Dashboard.
3. Ensures `iptables` rules are persistent across reboots using
`iptables-persistent`.
4. Installs Dokploy if it is not already present, or updates it if it is.

### Usage

#### As Cloud-init User Data

When creating a new OCI instance, you can provide the contents of
`scripts/init.sh` as the **Cloud-init script** (User Data) to automate the
entire setup process.

#### Manual Execution

You can also run the script manually on an existing Ubuntu instance:

```bash
sudo ./scripts/init.sh
```

### Managing Deployments with Dokploy

Once Dokploy is installed, you can access the dashboard at
`http://<your-instance-ip>:3000`.

Dokploy allows you to easily manage and deploy:

- **Docker Compose Stacks**: Deploy complex multi-container applications by
providing your `docker-compose.yml` directly in the Dokploy interface.
- **Applications**: Deploy web applications from GitHub, GitLab, or Bitbucket.
- **Databases**: Easily provision and manage PostgreSQL, MySQL, MongoDB, and
Redis instances.
