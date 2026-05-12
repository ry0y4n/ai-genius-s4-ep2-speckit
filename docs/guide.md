# AI Genius: Season 4 Episode 2

## Spec-Kit with GitHub Copilot Instructor Runbook

This guide is the dry-run and live-show script. The live show starts from a prepared repository state: infrastructure is already specified, the infra workflow is complete, and dev Azure resources already exist. The live work is to create the frontend deployment workflow with Spec-Kit and prove that a code change reaches Azure Static Web Apps.

## Demo Contract

| Area | Decision |
|------|----------|
| Repository | `ry0y4n/ai-genius-s4-ep2-speckit` |
| Starting feature | `001-bicep-cicd-workflow` complete |
| Live feature | `002-frontend-ci-cd` |
| Live Azure environment | `dev` |
| Resource group | `rg-aigenius-dev` |
| Static Web App | `aigenius-frontend-dev` |
| API App Service | `aigenius-api-dev` |
| Static Web App location | `eastus2` |
| API App Service location | `japanwest` |
| Azure auth | GitHub OIDC with `azure/login@v2` |
| Long-lived Azure secret | Not used |

## Instructor Preflight

Run this before restarting the dry run or before the live show.

### Local Tooling

```bash
node --version
npm --version
dotnet --version
az --version
git --version
gh --version
specify check
```

Expected:

- Node.js 20+
- .NET 9 SDK
- Azure CLI authenticated with `az login`
- GitHub CLI authenticated with `gh auth login`
- Spec-Kit installed for GitHub Copilot

### Repository State

```bash
git status --short --branch
git branch --show-current
ls specs
ls .github/workflows
```

Expected at live start:

```text
specs/001-bicep-cicd-workflow
.github/workflows/deploy-infra.yml
```

Do not start the live show with `deploy-web.yml`, `deploy-api.yml`, or `ci.yml` already present unless you are intentionally showing the completed end state.

### GitHub Secrets

```bash
gh secret list -R ry0y4n/ai-genius-s4-ep2-speckit
```

Required repository secrets:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

`AZURE_CREDENTIALS` is not required.

### Azure OIDC Setup

Create the Entra application and federated credentials once. Because the workflow uses GitHub Environments, configure one subject per environment:

```bash
APP_ID=$(az ad app create --display-name "ai-genius-cicd" --query appId -o tsv)
APP_OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)
SP_OBJECT_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv)

for ENVIRONMENT in dev qa prod; do
  az ad app federated-credential create \
    --id "$APP_OBJECT_ID" \
    --parameters "{\"name\":\"github-env-${ENVIRONMENT}\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:${ENVIRONMENT}\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
done
```

Grant access for the demo subscription:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

Set repository secrets:

```bash
gh secret set AZURE_CLIENT_ID --repo ry0y4n/ai-genius-s4-ep2-speckit --body "$APP_ID"
gh secret set AZURE_TENANT_ID --repo ry0y4n/ai-genius-s4-ep2-speckit --body "$(az account show --query tenantId -o tsv)"
gh secret set AZURE_SUBSCRIPTION_ID --repo ry0y4n/ai-genius-s4-ep2-speckit --body "$(az account show --query id -o tsv)"
```

### Azure Baseline Deployment

Before the live show, run **Actions -> Deploy Infrastructure to Azure -> Run workflow -> dev**.

Verify:

```bash
az resource list \
  --resource-group rg-aigenius-dev \
  --query "[].{name:name,type:type,tags:tags}" \
  --output table
```

Expected resources:

- `aigenius-plan-dev`
- `aigenius-api-dev`
- `aigenius-frontend-dev`

Keep the successful workflow run and Azure resource group open as fallback tabs.

## Part 0: Demo Apps

The repository contains two small apps.

### React Frontend

Path: `src/ai-genius-web`

- React 18
- Vite
- Reads API base URL from `VITE_API_URL`
- Calls `/api/status` and `/api/series`

Local check:

```bash
cd src/ai-genius-web
npm ci
npm run build
```

### .NET API

Path: `src/ai-genius-api`

- .NET 9 Minimal API
- Swagger UI at `http://localhost:5151/swagger/index.html`
- Health endpoint: `/api/health`

Local check:

```bash
dotnet build ai-genius-s4-ep2-speckit.sln
```

## Part 1: Spec-Kit Setup

Use this part only if starting from a fresh clone or explaining how the repo was prepared. The current demo repository is already initialized.

Install Spec-Kit if needed:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.6.1
```

Initialize for GitHub Copilot if needed:

```bash
specify init . --ai copilot
specify extension add git
specify check
```

Explain the command flow:

```text
/speckit.constitution
/speckit.specify
/speckit.clarify
/speckit.checklist
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
```

## Part 2: Existing Infrastructure Spec

Goal: show that a completed spec becomes the source of truth for implemented infrastructure.

Open:

```text
specs/001-bicep-cicd-workflow/spec.md
specs/001-bicep-cicd-workflow/plan.md
specs/001-bicep-cicd-workflow/tasks.md
.github/workflows/deploy-infra.yml
bicep/main.bicep
```

Talk track:

1. `001` is complete before the live show.
2. It provisions Azure resources only.
3. It uses OIDC, not `AZURE_CREDENTIALS`.
4. It creates `rg-aigenius-dev` and deploys the API App Service plus Static Web App.
5. Later workflows target these existing resources.

Do not spend live time waiting for infra unless the session goal is timing validation. For dry runs, measure it once and record the duration.

## Part 3: Frontend CI/CD Live Demo

Goal: create a frontend deployment workflow from a new specification, then prove that a code change is deployed to Azure Static Web Apps.

### 3.1 Create the Feature Branch

In Copilot Chat:

```text
/speckit.git.feature frontend-ci-cd
```

Expected feature folder:

```text
specs/002-frontend-ci-cd/
```

### 3.2 Specify

Use this prompt:

```text
/speckit.specify Deploy the AI Genius React frontend web app via GitHub Actions.
The frontend is a React 18 + Vite app in src/ai-genius-web.
Create .github/workflows/deploy-web.yml.
The workflow should:
1. Trigger on every push to main.
2. Set up Node.js 20.
3. Run npm ci and npm run build in src/ai-genius-web.
4. Build with VITE_API_URL set to https://aigenius-api-dev.azurewebsites.net.
5. Authenticate to Azure using OIDC with azure/login@v2.
6. Retrieve the Azure Static Web Apps deployment token at runtime with az staticwebapp secrets list.
7. Deploy the built dist folder to the existing Static Web App aigenius-frontend-dev in rg-aigenius-dev using Azure/static-web-apps-deploy@v1.
Use only AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_SUBSCRIPTION_ID repository secrets. Do not use AZURE_CREDENTIALS and do not store the Static Web Apps deployment token as a GitHub secret.
The success signal is a green Actions run and the visible frontend change appearing on the Azure Static Web Apps URL.
```

### 3.3 Clarify

Use this prompt if Copilot asks for details:

```text
/speckit.clarify The Azure infrastructure already exists before the live demo.
Target resource group: rg-aigenius-dev.
Target Static Web App: aigenius-frontend-dev.
Target API URL for the frontend build: https://aigenius-api-dev.azurewebsites.net.
The workflow file is .github/workflows/deploy-web.yml.
The workflow uses id-token: write and contents: read permissions.
```

### 3.4 Checklist, Plan, Tasks, Analyze

Run these one at a time:

```text
/speckit.checklist
/speckit.plan
/speckit.tasks
/speckit.analyze
```

Planning prompt if needed:

```text
Use GitHub Actions on ubuntu-latest. Steps are checkout, setup-node, npm ci, npm run build with VITE_API_URL, azure/login@v2, az staticwebapp secrets list, and Azure/static-web-apps-deploy@v1 with skip_app_build: true and app_location set to src/ai-genius-web/dist.
```

### 3.5 Implement

In the active feature branch:

```text
/speckit.implement
```

Expected created file:

```text
.github/workflows/deploy-web.yml
```

Review the workflow before merge. The important checks are:

- `permissions.id-token: write`
- `azure/login@v2`
- `npm ci`
- `npm run build`
- `VITE_API_URL=https://aigenius-api-dev.azurewebsites.net`
- `az staticwebapp secrets list --name aigenius-frontend-dev --resource-group rg-aigenius-dev`
- `Azure/static-web-apps-deploy@v1`

### 3.6 Show Code Change Reaching Azure

Make a small visible frontend change, for example update the header subtitle in `src/ai-genius-web/src/App.jsx`.

Then merge to `main` or push the prepared branch according to the show format.

Watch:

1. GitHub Actions -> `Deploy Web to Azure Static Web Apps`.
2. `npm ci`.
3. `npm run build`.
4. Azure login.
5. Static Web Apps deploy.

Verify:

1. Open the Static Web App URL.
2. Confirm the visible text change appears.
3. Confirm the app still loads episode data from the API.

## Part 4: API Deployment Speed Run

This part is optional for the main live story. Use it if there is time after the frontend deploy succeeds.

Create a new feature:

```text
/speckit.git.feature api-ci-cd
```

Specify prompt:

```text
/speckit.specify Deploy the AI Genius .NET 9 API via GitHub Actions.
The API project is src/ai-genius-api/ai-genius-api.csproj.
Create .github/workflows/deploy-api.yml.
The workflow triggers on push to main, sets up .NET 9, runs dotnet publish, zips the published output, authenticates to Azure with OIDC, and deploys to the existing App Service aigenius-api-dev in rg-aigenius-dev using azure/webapps-deploy@v3.
The health endpoint /api/health must return a JSON response with status set to healthy.
```

Then run:

```text
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

## Part 5: Quality Gates

Use this as the final demo step or as a discussion topic if time is short.

Create a new feature:

```text
/speckit.git.feature quality-gates
```

Specify prompt:

```text
/speckit.specify Add quality gates to the AI Genius CI/CD pipeline.
Create .github/workflows/ci.yml that runs on pull requests to main.
It should build the frontend with npm ci and npm run build, and build the API with dotnet build.
Document that branch protection and environment approvals are configured in GitHub Settings, not entirely in workflow files.
The dev environment has no approval gate. QA and production approval gates are future configuration steps.
```

Then run:

```text
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

## Timing Sheet

Use this during dry runs.

| Segment | Start | End | Duration | Notes |
|---------|-------|-----|----------|-------|
| Local app build check | | | | |
| Infra workflow dev run | | | | Pre-live only |
| Frontend specify to tasks | | | | |
| Frontend implement | | | | |
| Frontend deploy run | | | | |
| Azure verification | | | | |

## Live Fallbacks

Prepare these before the show:

- Successful infra workflow run.
- Successful frontend deploy workflow run from dry run.
- Azure Static Web App URL with the final frontend loaded.
- Azure resource group overview.
- A local copy of the expected `deploy-web.yml` for comparison.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Azure login fails with `AADSTS70021` | Federated credential subject mismatch | Recreate the credential for `repo:ry0y4n/ai-genius-s4-ep2-speckit:environment:dev` |
| Workflow cannot find `package-lock.json` | Running from wrong directory | Ensure `working-directory: src/ai-genius-web` and cache path `src/ai-genius-web/package-lock.json` |
| Static Web Apps deploy cannot authenticate | Token retrieval failed | Check `az staticwebapp secrets list` uses `aigenius-frontend-dev` and `rg-aigenius-dev` |
| Frontend deploys but cannot load episodes | Missing `VITE_API_URL` or API CORS | Check build env and App Service `AllowedOrigins__*` settings |
| API health check expectation mismatch | Wrong expected JSON | Current API returns `status: healthy` from `/api/health` |

## Wrap-Up Message

Specifications are the source of truth. The infrastructure feature was completed before the show, and the live feature turned a frontend deployment requirement into a working GitHub Actions workflow that shipped a visible change to Azure.