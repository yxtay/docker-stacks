# OCI Resource Manager — ARM Free Tier VPS

Modular Terraform stack for OCI Resource Manager that provisions an Ampere A1
(ARM) Always Free VPS (4 OCPU / 24 GB RAM / 200 GB boot volume).

The cloud-init template (`templates/cloud-init.yaml`) configures iptables
(ports 80, 443, 9443), installs Docker, and adds the `ubuntu` user to the
docker group. The Terraform stack uses it automatically.

Required inputs: **Compartment**, **SSH Public Key**, and optionally
**Cloud-init Configuration** (defaults to `templates/cloud-init.yaml`).

## Deploy via OCI Console

```bash
cd oci-rm && zip -r ../oci-rm-stack.zip . && cd ..
```

Upload `oci-rm-stack.zip` via **Developer Services → Resource Manager → Stacks
→ Create Stack**, fill in the form, and click **Apply**.

## Deploy via OCI CLI

```bash
# Update existing stack config
STACK_ID=<stack-ocid> bash bin/oci-rm-stack-update.sh
```

## Apply via cron (out-of-capacity retry)

`bin/oci-rm-stack-apply.sh` retries apply idempotently — skips when already
succeeded or in progress, and only retries after capacity-related failures.

```bash
# Cron example (every 10 minutes)
*/10 * * * * STACK_ID=<stack-ocid> /path/to/bin/oci-rm-stack-apply.sh
```
