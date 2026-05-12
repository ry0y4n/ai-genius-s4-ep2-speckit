targetScope = 'resourceGroup'

// ── Parameters ───────────────────────────────────────────────

@description('Base name used to derive all resource names.')
@minLength(3)
@maxLength(20)
param appName string = 'aigenius'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Deployment environment tag (dev | qa | prod).')
@allowed(['dev', 'qa', 'prod'])
param environment string = 'dev'

@description('SKU for the App Service Plan.')
@allowed(['F1', 'B1', 'B2', 'S1'])
param appServicePlanSku string = 'F1'

@description('SKU for the Static Web App.')
@allowed(['Free', 'Standard'])
param staticWebAppSku string = 'Free'

// ── Modules ──────────────────────────────────────────────────

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebAppDeploy'
  params: {
    appName: appName
    location: location
    environment: environment
    sku: staticWebAppSku
  }
}

module webApp 'modules/webapp.bicep' = {
  name: 'webAppDeploy'
  params: {
    appName: appName
    location: location
    environment: environment
    appServicePlanSku: appServicePlanSku
    allowedOrigins: [
      'http://localhost:5173'
      staticWebApp.outputs.url
    ]
  }
}

// ── Outputs ──────────────────────────────────────────────────

@description('URL of the deployed React static web app.')
output staticWebAppUrl string = staticWebApp.outputs.url

@description('Name of the deployed React static web app.')
output staticWebAppName string = staticWebApp.outputs.name

@description('Name of the deployed API App Service.')
output apiAppName string = webApp.outputs.name

@description('Default hostname of the deployed API App Service.')
output apiAppHostname string = webApp.outputs.hostname

@description('URL of the deployed API App Service.')
output apiAppUrl string = webApp.outputs.url

@description('Resource ID of the App Service.')
output apiAppResourceId string = webApp.outputs.resourceId
