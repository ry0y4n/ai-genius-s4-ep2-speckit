# Data Model: Pre-Live Azure Infrastructure Deployment

**Branch**: `001-bicep-cicd-workflow` | **Date**: 2026-05-12

## Entities

### 1. `InfrastructureWorkflow`

| Field | Value |
|-------|-------|
| File | `.github/workflows/deploy-infra.yml` |
| Triggers | `push` to `main`, `workflow_dispatch` |
| Auth | OIDC through `azure/login@v2` |
| Target environments | `dev`, `qa`, `prod` |
| Live environment | `dev` |

### 2. `EnvironmentTarget`

| Environment | Resource group | Parameter file |
|-------------|----------------|----------------|
| `dev` | `rg-aigenius-dev` | `bicep/parameters.dev.json` |
| `qa` | `rg-aigenius-qa` | `bicep/parameters.qa.json` |
| `prod` | `rg-aigenius-prod` | `bicep/parameters.prod.json` |

### 3. `OidcIdentity`

| Field | Value |
|-------|-------|
| Client ID | `AZURE_CLIENT_ID` repository secret |
| Tenant ID | `AZURE_TENANT_ID` repository secret |
| Subscription ID | `AZURE_SUBSCRIPTION_ID` repository secret |
| Federated subject | `repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:<environment>` |

### 4. `BicepDeployment`

| Field | Value |
|-------|-------|
| Deployment name | `main-deploy` |
| Template | `bicep/main.bicep` |
| Scope | Resource group |
| Mode | Incremental |

### 5. `AzureResource`

| Resource | Naming pattern | Purpose |
|----------|----------------|---------|
| App Service Plan | `aigenius-plan-<env>` | Hosts API compute |
| API App Service | `aigenius-api-<env>` | Hosts `.NET 9` API |
| Static Web App | `aigenius-frontend-<env>` | Hosts React/Vite frontend |

### 6. `WorkflowOutput`

| Output | Source |
|--------|--------|
| `api-app-name` | Bicep `apiAppName` output |
| `api-app-url` | Bicep `apiAppUrl` output |
| `static-web-app-name` | Bicep `staticWebAppName` output |
| `static-web-app-url` | Bicep `staticWebAppUrl` output |

## Relationships

```text
InfrastructureWorkflow
  -> OidcIdentity
  -> EnvironmentTarget
  -> BicepDeployment
      -> App Service Plan
      -> API App Service
      -> Static Web App
  -> WorkflowOutput
```

## Validation Rules

- `environment` must be one of `dev`, `qa`, or `prod`.
- The matching parameter file must exist.
- API CORS settings must include the deployed Static Web App URL.
- No Static Web App deployment token is emitted by the infrastructure workflow.