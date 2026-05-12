# Quickstart: Pre-Live Azure Infrastructure Deployment

**Feature**: `001-bicep-cicd-workflow` | **Date**: 2026-05-12

Use this before the live show to make sure the Azure baseline is ready.

## Prerequisites

- Azure subscription with permission to create resource groups and assign roles.
- GitHub repository: `ry0y4n/ai-genius-s4-ep2-speckit`.
- GitHub Actions enabled.
- Azure CLI authenticated locally for one-time setup.
- GitHub CLI authenticated if using CLI commands to set secrets.

## Step 1: Create Entra Application and Federated Credential

```bash
APP_ID=$(az ad app create --display-name "ai-genius-cicd" --query appId -o tsv)
az ad sp create --id "$APP_ID"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ry0y4n/ai-genius-s4-ep2-speckit:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Step 2: Grant Azure Access

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az role assignment create \
  --assignee "$APP_ID" \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

Subscription scope keeps the demo simple because the workflow creates the resource group if needed.

## Step 3: Add GitHub Repository Secrets

```bash
gh secret set AZURE_CLIENT_ID --body "$APP_ID"
gh secret set AZURE_TENANT_ID --body "$(az account show --query tenantId -o tsv)"
gh secret set AZURE_SUBSCRIPTION_ID --body "$(az account show --query id -o tsv)"
```

## Step 4: Run the Infrastructure Workflow

1. Open GitHub Actions.
2. Select **Deploy Infrastructure to Azure**.
3. Click **Run workflow**.
4. Choose `dev`.
5. Wait for the run to complete.

## Step 5: Verify Azure Resources

```bash
az resource list \
  --resource-group rg-aigenius-dev \
  --query "[].{name:name, type:type, tags:tags}" \
  --output table
```

Expected resources:

- `aigenius-plan-dev`
- `aigenius-api-dev`
- `aigenius-frontend-dev`

## Step 6: Capture Live Fallbacks

Before the live show, keep these tabs or screenshots ready:

- Successful `Deploy Infrastructure to Azure` workflow run.
- Azure resource group `rg-aigenius-dev`.
- Static Web App overview page.
- API App Service overview page.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `AADSTS70021` | Federated credential subject mismatch | Confirm the subject uses `ry0y4n/ai-genius-s4-ep2-speckit` and `refs/heads/main` |
| `AuthorizationFailed` | App registration lacks Contributor | Re-run the role assignment or scope it to the subscription |
| Missing parameter file | Wrong environment value | Use `dev`, `qa`, or `prod` |
| Frontend deploy later cannot call API | API CORS or `VITE_API_URL` mismatch | Confirm Bicep deployed CORS settings and frontend build env |