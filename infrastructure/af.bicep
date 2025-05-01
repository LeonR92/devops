@description('The base name for resources. MUST be globally unique for storage account and function app name.')
@minLength(3)
@maxLength(24)
param baseName string = 'flaskfuncmin${uniqueString(resourceGroup().id)}'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location


@description('The Python version for the Function App runtime (e.g., 3.9, 3.10, 3.11).')
@allowed([
  '3.9'
  '3.10'
  '3.11'
])
param pythonVersion string = '3.10' // PYTHON version

var storageAccountName = toLower('${take(replace(baseName, '-',''), 14)}st${uniqueString(resourceGroup().id)}')
var appServicePlanName = '${baseName}-plan'
var functionAppName = '${baseName}-app'

// --- Resources ---

// storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Consumption app
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1' 
    tier: 'Dynamic'
  }
  kind: 'linux' 
  properties: {
    reserved: true 
  }
}

// Function App 
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux' // Linux
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|${pythonVersion}' // Sets the Python runtime
      appSettings: [
        {
          name: 'AzureWebJobsStorage' 
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' 
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE' 
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4' // V4 runtime
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python' // Python worker
        }

      ]
      ftpsState: 'FtpsOnly' 
      minTlsVersion: '1.2'
    }
    httpsOnly: true 
    clientAffinityEnabled: false
  }
  dependsOn: [
    storageAccount,
    appServicePlan
  ]
}

// --- Outputs ---

output functionAppName string = functionApp.name
output functionAppHostname string = functionApp.properties.defaultHostName
