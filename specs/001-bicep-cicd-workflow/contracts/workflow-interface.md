# Workflow Interface Contract

**Feature**: `001-bicep-cicd-workflow`
**File**: `.github/workflows/deploy-infra.yml`
**Date**: 2026-05-12

## Triggers

| Trigger | Condition | Default environment |
|---------|-----------|---------------------|
| `push` | Branch `main` | `dev` |
| `workflow_dispatch` | Manual via GitHub UI | `dev` |

## Inputs

| Input name | Type | Required | Default | Allowed values |
|------------|------|----------|---------|----------------|
| `environment` | `choice` | Yes | `dev` | `dev`, `qa`, `prod` |

## Required Repository Secrets

| Secret name | Description | Sensitive? |
|-------------|-------------|------------|
| `AZURE_CLIENT_ID` | Entra application client ID for OIDC | No, identifier |
| `AZURE_TENANT_ID` | Azure tenant ID | No, identifier |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | No, identifier |

`AZURE_CREDENTIALS` is not used.

## Azure Federated Credential

For the live demo repository, configure these subjects on the Entra application because the workflow uses GitHub Environments:

```text
repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:dev
repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:qa
repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:prod
```

## Job Outputs

| Output name | Description |
|-------------|-------------|
| `resource-group` | Target Azure resource group |
| `api-app-name` | API App Service name |
| `api-app-url` | API App Service URL |
| `static-web-app-name` | Static Web App name |
| `static-web-app-url` | Static Web App URL |

The workflow also writes these values to the GitHub Actions step summary for easy live-demo copy/paste.

## Guarantees

| # | Guarantee | Failure mode |
|---|-----------|--------------|
| G1 | Login uses OIDC only | Missing or mismatched federated credential causes Azure login to fail |
| G2 | Resource group exists before Bicep deploy | `az group create` fails before template deployment |
| G3 | Parameter file matches selected environment | Missing `bicep/parameters.<env>.json` fails before Azure resources are changed |
| G4 | Later workflows can target stable dev resources | Outputs and run summary show the exact names and URLs |

## Breaking Changes

- Renaming required secrets.
- Removing OIDC permissions.
- Changing resource naming without updating the live guide.
- Exposing Static Web App deployment tokens from the infra workflow.