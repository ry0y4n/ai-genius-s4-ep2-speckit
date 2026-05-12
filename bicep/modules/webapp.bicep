// ============================================================
// modules/webapp.bicep
//
// Provisions an Azure App Service Plan and Web App to run
// the .NET API from src/ai-genius-api.
// ============================================================

@description('Base name used to derive resource names.')
param appName string

@description('Azure region for the resources.')
param location string

@description('Deployment environment tag.')
param environment string

@description('App Service Plan SKU.')
@allowed(['F1', 'B1', 'B2', 'S1'])
param appServicePlanSku string = 'B1'

@description('.NET runtime version for the web app.')
param dotnetVersion string = 'DOTNETCORE|9.0'

@description('Origins allowed to call the API from browsers.')
param allowedOrigins array = [
  'http://localhost:5173'
]

var corsAppSettings = [for (origin, index) in allowedOrigins: {
  name: 'AllowedOrigins__${index}'
  value: origin
}]

// ── App Service Plan ─────────────────────────────────────────

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appName}-plan-${environment}'
  location: location
  tags: {
    app: appName
    component: 'api'
    environment: environment
    managedBy: 'bicep'
  }
  sku: {
    name: appServicePlanSku
  }
  kind: 'linux'
  properties: {
    reserved: true // required for Linux plans
  }
}

// ── Web App ───────────────────────────────────────────────────

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appName}-api-${environment}'
  location: location
  tags: {
    app: appName
    component: 'api'
    environment: environment
    managedBy: 'bicep'
  }
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: dotnetVersion
      alwaysOn: appServicePlanSku != 'F1'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: concat([
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ], corsAppSettings)
    }
  }
}

// ── Outputs ──────────────────────────────────────────────────

@description('Name of the web app.')
output name string = webApp.name

@description('Default hostname of the web app.')
output hostname string = webApp.properties.defaultHostName

@description('HTTPS URL of the web app.')
output url string = 'https://${webApp.properties.defaultHostName}'

@description('Resource ID of the web app.')
output resourceId string = webApp.id

@description('Resource ID of the App Service Plan.')
output planResourceId string = appServicePlan.id
