# Tasks: Pre-Live Azure Infrastructure Deployment

**Feature**: `001-bicep-cicd-workflow`
**Generated**: 2026-05-12
**Input**: `specs/001-bicep-cicd-workflow/plan.md`, `spec.md`, `data-model.md`, `contracts/workflow-interface.md`, `research.md`, `quickstart.md`

## Phase 1: Infrastructure Workflow Baseline

- [X] T001 Create `.github/workflows/deploy-infra.yml` with `push` to `main` and manual `workflow_dispatch` triggers.
- [X] T002 Add workflow-level `permissions: contents: read` and `id-token: write` for OIDC.
- [X] T003 Add `azure/login@v2` using `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`.
- [X] T004 Remove dependency on `AZURE_CREDENTIALS`.
- [X] T005 Resolve `environment` to `dev`, `qa`, or `prod`, and derive resource group and parameter file names.
- [X] T006 Create the target resource group with `az group create`.
- [X] T007 Deploy `bicep/main.bicep` with `bicep/parameters.<environment>.json`.
- [X] T008 Capture API and Static Web App names and URLs into workflow outputs and the run summary.

## Phase 2: Bicep Infrastructure

- [X] T009 Keep `bicep/parameters.dev.json`, `bicep/parameters.qa.json`, and `bicep/parameters.prod.json` available.
- [X] T010 Provision Azure Static Web Apps from `bicep/modules/staticwebapp.bicep`.
- [X] T011 Provision Azure App Service Plan and API App Service from `bicep/modules/webapp.bicep`.
- [X] T012 Apply tags `app`, `component`, `environment`, and `managedBy` to all Azure resources.
- [X] T013 Configure the API App Service for .NET 9.
- [X] T014 Configure API CORS app settings so the Static Web App origin is allowed.
- [X] T015 Output API and Static Web App names and URLs from `bicep/main.bicep`.

## Phase 3: Demo Readiness

- [X] T016 Document required repository secrets in the workflow contract and quickstart.
- [X] T017 Document that this feature is pre-live infrastructure only; frontend and API deployment workflows are later specs.
- [ ] T018 Run the `dev` infrastructure workflow in GitHub Actions before the live show.
- [ ] T019 Verify `rg-aigenius-dev` contains the expected Azure resources.
- [ ] T020 Capture fallback screenshots or browser tabs for the successful workflow run and Azure resources.

## Dependencies

T001 -> T002 -> T003 -> T005 -> T006 -> T007 -> T008
T009 -> T010/T011 -> T012/T013/T014 -> T015
T018 depends on all implementation tasks.

## Notes

This feature intentionally does not create `deploy-web.yml`, `deploy-api.yml`, or `ci.yml`. Those files are generated during later live demo features.