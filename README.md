<div align="center">

<h1>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/azure/azure-original.svg" height="30" alt="Azure"/>
  &nbsp;Azure Infrastructure as Code with Terraform&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" height="30" alt="Terraform"/>
</h1>

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9-7B42BC?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-francecentral-0078D4?logo=microsoftazure&logoColor=white)
![Provider](https://img.shields.io/badge/azurerm-~%3E4.0-0078D4)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-OIDC-2088FF?logo=githubactions&logoColor=white)
![State](https://img.shields.io/badge/state-HCP_Terraform_(cloud)-844FBA?logo=terraform&logoColor=white)
![Auth](https://img.shields.io/badge/auth-OIDC_(no_secret)-brightgreen)

</div>

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
GitHub push / PR (main)
      │
      ▼
GitHub Actions ── OIDC (JWT, no secret) ──► Azure
      │
      ├─ quality (fmt) / lint / plan
      └─ apply (production env, manual approval)
                 │
                 ▼
         Azure resources ◄── remote state ── HCP Terraform (cloud backend)
```

## Tech stack

- **Terraform** `>= 1.9`, provider `azurerm ~> 4.0`
- **Azure** region `francecentral`
- **Remote state**: HCP Terraform (cloud backend), organization `WhiteMuush-Organizations`, workspace `simplon-terraform-tp`. State and locking managed by HCP, authenticated with a `TF_API_TOKEN`
- **Auth**: Azure via OIDC federated credentials, zero `CLIENT_SECRET` stored anywhere
- **CI/CD**: GitHub Actions with a reusable workflow + a composite action for the Azure login

## Repository layout

```
starter/terraform/
├── main.tf            # data sources + module wiring
├── providers.tf       # azurerm ~> 4.0, use_oidc = true
├── backend.tf         # HCP Terraform cloud backend (org + workspace)
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

`ci.yml` triggers on **push and pull_request** to `main`. It runs a `build` gate then calls the reusable `terraform.yml`, which runs four sequential jobs:

1. **quality** — `terraform fmt -check -recursive`
2. **lint** — `terraform-lint`
3. **build** — OIDC login, `terraform init`, `terraform plan`
4. **deploy** — `production` environment (manual approval gate), OIDC login, `terraform init`, `terraform apply -auto-approve`

Azure auth is handled by the `oidc` composite action wrapping `azure/login@v2`. Four secrets are needed: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (Azure, no client secret) and `TF_API_TOKEN` (HCP Terraform backend + registry).

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

# authenticate to HCP Terraform once (opens browser, stores token)
terraform login
# or export TF_TOKEN_app_terraform_io=<your HCP token>

terraform init   # state lives in HCP, no -backend-config needed
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
