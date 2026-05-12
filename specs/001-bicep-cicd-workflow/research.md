# Research: Pre-Live Azure Infrastructure Deployment

**Branch**: `001-bicep-cicd-workflow` | **Date**: 2026-05-12

## 1. Azure Authentication

**Decision**: Use `azure/login@v2` with OIDC.

**Rationale**: OIDC avoids storing long-lived Azure credentials in GitHub. The workflow needs only identifier secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`.

**Rejected alternative**: `azure/login` with `creds: ${{ secrets.AZURE_CREDENTIALS }}` because it requires a client secret JSON blob.

## 2. Live Demo Scope

**Decision**: The infrastructure workflow is complete before the live show. The live show creates the frontend deployment workflow as the next Spec-Kit feature.

**Rationale**: Azure resource provisioning can take variable time. Pre-provisioning keeps the live focus on specification-driven workflow generation and code-to-cloud deployment.

## 3. Workflow Shape

**Decision**: Keep `deploy-infra.yml` infrastructure-only.

**Rationale**: Separate workflows make the demo easier to explain:

- `deploy-infra.yml`: pre-live infrastructure baseline
- `deploy-web.yml`: generated live for frontend deployment
- `deploy-api.yml`: generated later for API deployment
- `ci.yml`: generated later for quality gates

## 4. Environment Values

**Decision**: Use `dev`, `qa`, and `prod` directly.

**Rationale**: The Bicep template already accepts these values, and the live show uses `dev` only. Avoiding `development` to `dev` mapping keeps the workflow easier to read.

## 5. Static Web App Deployment Token

**Decision**: Do not expose the token from the infrastructure workflow.

**Rationale**: The frontend workflow can retrieve the token at deploy time through Azure CLI after OIDC login. This keeps the infra workflow focused on resource creation and avoids copying deployment tokens through job outputs.

## 6. Frontend/API Connectivity

**Decision**: The API App Service allows the Static Web App URL through app settings, and the frontend deployment workflow builds with `VITE_API_URL` pointing to the API URL.

**Rationale**: This prevents the common live-demo failure where deployment succeeds but the browser cannot fetch API data.