# Azure Infrastructure as Code with Terraform

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9-7B42BC?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-francecentral-0078D4?logo=microsoftazure&logoColor=white)
![Provider](https://img.shields.io/badge/azurerm-~%3E4.0-0078D4)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-OIDC-2088FF?logo=githubactions&logoColor=white)
![State](https://img.shields.io/badge/state-Azure_Blob_(remote)-success)
![Auth](https://img.shields.io/badge/auth-OIDC_(no_secret)-brightgreen)

Provisioning of a full Azure application stack, described entirely as code with Terraform and shipped through a passwordless GitHub Actions pipeline. Same resources I previously created by hand with the Azure CLI, now versioned, reproducible and deployed automatically.

> This is my work write-up. The original assignment (French) lives in [`CONSIGNES.md`](CONSIGNES.md).

## What this deploys

| Module | Azure resource | Purpose |
|--------|----------------|---------|
| `storage` | Storage Account + 2 containers (`api-logs` private, `api-config` public) | Application storage |
| `app-service` | Linux Web App (Python 3.11, HTTPS only, TLS 1.2) | Web API |
| `function-app` | Linux Function App + dedicated Storage Account | Serverless functions |
| `container` | Container Group (nginx, public FQDN) | Containerized service |
| `network` | VNet + 2 subnets + NSG (HTTP/HTTPS allow, deny-all) + association | Network layer |

All resources are tagged `managed_by = terraform`, `environment = tp`, `owner = <me>` via a shared `local.tags` merge.

## Architecture

```
GitHub push (main)
      │
      ▼
GitHub Actions ── OIDC (JWT, no secret) ──► Azure
      │
      ├─ fmt / lint / validate / plan
      └─ apply
                 │
                 ▼
         Azure resources ◄── remote state ── Azure Blob Storage (locked)
```

## Tech stack

- **Terraform** `>= 1.9`, provider `azurerm ~> 4.0`
- **Azure** region `francecentral`
- **Remote state**: Azure Blob Storage backend, injected at runtime via `-backend-config` (no account names committed)
- **Auth**: OIDC federated credentials, zero `CLIENT_SECRET` stored anywhere
- **CI/CD**: GitHub Actions with a reusable workflow + a composite action for the Azure login

## Repository layout

```
starter/terraform/
├── main.tf            # data sources + module wiring
├── providers.tf       # azurerm ~> 4.0, use_oidc = true
├── backend.tf         # azurerm remote backend (values injected at runtime)
├── variables.tf       # owner, resource_group_name, location, tags (with validation)
├── outputs.tf         # app / function / container URLs + storage name
└── modules/
    ├── storage/
    ├── app-service/
    ├── function-app/
    ├── container/
    └── network/
.github/
├── workflows/ci.yml         # entry pipeline on push to main
├── workflows/terraform.yml  # reusable: quality → lint → build(plan) → deploy(apply)
└── actions/oidc/action.yml  # composite action, azure/login via OIDC
Makefile               # local mirror of the CI steps
```

## CI/CD pipeline

`ci.yml` triggers on push to `main` and calls the reusable `terraform.yml`, which runs four sequential jobs:

1. **quality** — `terraform fmt -check -recursive`
2. **lint** — `terraform-lint`
3. **build** — OIDC login, `terraform init` (remote backend), `terraform plan`
4. **deploy** — OIDC login, `terraform init`, `terraform apply -auto-approve`

Azure auth is handled by the `oidc` composite action wrapping `azure/login@v2`. Only three secrets are needed: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`. No client secret.

## Run it locally

```bash
# lint + init + validate + plan (same as CI build job)
make test-ci

# full run including apply
make test-cd
```

Or directly:

```bash
cd starter/terraform
terraform init \
  -backend-config="resource_group_name=<rg>" \
  -backend-config="storage_account_name=<sa>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=<owner>.terraform.tfstate"
terraform plan
terraform apply
```

## Outputs

After apply, Terraform prints the endpoints so there is no need to browse the Azure portal:

- `app_service_url` — App Service HTTPS URL
- `function_app_url` — Function App HTTPS URL
- `container_fqdn` — nginx container public FQDN
- `storage_account_name` — business Storage Account name

## Cleanup

```bash
cd starter/terraform
terraform destroy
# Resource Group is kept; only managed_by=terraform resources are removed
```

---

*DevSecOps Azure training, Simplon.*
