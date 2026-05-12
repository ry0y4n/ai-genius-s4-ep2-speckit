# Implementation Plan: Pre-Live Azure Infrastructure Deployment

**Branch**: `001-bicep-cicd-workflow` | **Date**: 2026-05-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-bicep-cicd-workflow/spec.md`

## Summary

Complete `.github/workflows/deploy-infra.yml` as the pre-live infrastructure workflow. It uses GitHub OIDC to log in to Azure, creates the target resource group, deploys `bicep/main.bicep`, and writes the API and Static Web App names and URLs to the run summary. The workflow provisions infrastructure only; frontend and API code deployment workflows are created by later live specs.

## Technical Context

**Language/Version**: GitHub Actions YAML, Bicep, Azure CLI
**Primary Dependencies**: `actions/checkout@v4`, `azure/login@v2`, Azure CLI
**Testing**: `az bicep build`, manual workflow run for `dev`, Azure resource inspection
**Target Platform**: GitHub Actions `ubuntu-latest`, Azure App Service, Azure Static Web Apps
**Project Type**: CI/CD infrastructure workflow
**Constraints**: OIDC only; no `AZURE_CREDENTIALS`; live demo targets `dev`
**Scope**: One infrastructure workflow, one Bicep entrypoint, three parameter files

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| Security-first | PASS | OIDC login, no client secret stored. |
| Cloud-native | PASS | Azure resources are defined with Bicep. |
| CI/CD-driven | PASS | Workflow runs from GitHub Actions. |
| Simplicity | PASS | One infra workflow and standard Azure actions. |
| Tested | PASS | Bicep build and dev workflow run validate the baseline. |

## Project Structure

```text
.github/workflows/
└── deploy-infra.yml

bicep/
├── main.bicep
├── parameters.dev.json
├── parameters.qa.json
├── parameters.prod.json
└── modules/
    ├── staticwebapp.bicep
    └── webapp.bicep
```

## Implementation Notes

- `deploy-infra.yml` accepts `dev`, `qa`, or `prod`; the live show uses `dev`.
- Resource groups follow `rg-aigenius-<environment>`.
- Static Web App names follow `aigenius-frontend-<environment>`.
- API App Service names follow `aigenius-api-<environment>`.
- The frontend workflow generated later should build with `VITE_API_URL` set to the API URL from this deployment.
- The Static Web App deployment token is not exposed by the infra workflow; later deployment workflows retrieve it at runtime with `az staticwebapp secrets list`.

## Verification Plan

1. Run `az bicep build --file bicep/main.bicep`.
2. Confirm `.github/workflows/deploy-infra.yml` parses as YAML.
3. Configure repository secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`.
4. Run `Deploy Infrastructure to Azure` manually with `environment=dev`.
5. Verify `rg-aigenius-dev` contains the App Service Plan, API App Service, and Static Web App.
6. Save the successful workflow run and Azure portal state as the fallback view for the live show.