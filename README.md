# AI Genius: Season 4 Episode 2

## Spec-Kit with GitHub Copilot

This repository is the live-demo workspace for showing specification-driven development with Spec-Kit and GitHub Copilot. The demo starts with Azure infrastructure already defined and deployed, then uses Spec-Kit live to generate CI/CD workflows for the application.

## Demo Starting State

At the start of the live show, this repository intentionally contains:

- A React/Vite frontend in `src/ai-genius-web`
- A .NET 9 Minimal API in `src/ai-genius-api`
- Bicep infrastructure in `bicep/`
- One completed Spec-Kit feature: `specs/001-bicep-cicd-workflow`
- One completed infrastructure workflow: `.github/workflows/deploy-infra.yml`

The frontend, API, and quality-gate workflows are created during the live demo as later Spec-Kit features.

## Live Demo Goal

The main live path is:

1. Review the completed `001` infrastructure spec and workflow.
2. Confirm the dev Azure infrastructure exists before the show.
3. Create a new frontend deployment spec with Spec-Kit.
4. Generate `.github/workflows/deploy-web.yml`.
5. Merge a frontend code change and show it deployed to Azure Static Web Apps.

## Full Guide

See [docs/guide.md](docs/guide.md) for the instructor runbook, pre-live checklist, and live commands.

## Local Development

Prerequisites:

- .NET 9 SDK
- Node.js 20+
- npm

Run the API:

```bash
cd src/ai-genius-api
dotnet run
```

Swagger is available at `http://localhost:5151/swagger/index.html`.

Run the frontend:

```bash
cd src/ai-genius-web
npm ci
npm run dev
```

The frontend dev server is available at `http://localhost:5173`.

## Azure Baseline

The pre-live infrastructure workflow provisions these dev resources:

| Resource | Name |
|----------|------|
| Resource group | `rg-aigenius-dev` |
| App Service Plan | `aigenius-plan-dev` |
| API App Service | `aigenius-api-dev` |
| Static Web App | `aigenius-frontend-dev` |

The Static Web App uses `eastus2`; the API App Service uses `japanwest` in this demo subscription because that region has available App Service quota.

For the live frontend CI/CD demo, the API code is pre-deployed manually to `aigenius-api-dev`. The API deployment workflow is still intentionally left for a later feature.

Required GitHub repository secrets:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

`AZURE_CREDENTIALS` is not used.

## Project Structure

```text
ai-genius-s4-ep2-speckit/
├── .github/
│   └── workflows/
│       └── deploy-infra.yml
├── bicep/
│   ├── main.bicep
│   ├── parameters.dev.json
│   ├── parameters.qa.json
│   ├── parameters.prod.json
│   └── modules/
│       ├── staticwebapp.bicep
│       └── webapp.bicep
├── docs/
│   └── guide.md
├── specs/
│   ├── constitution.md
│   └── 001-bicep-cicd-workflow/
└── src/
    ├── ai-genius-api/
    └── ai-genius-web/
```

## Created During the Live Demo

These files and folders are expected to appear during the show:

```text
specs/002-frontend-ci-cd/
.github/workflows/deploy-web.yml

specs/003-api-ci-cd/
.github/workflows/deploy-api.yml

specs/004-quality-gates/
.github/workflows/ci.yml
```