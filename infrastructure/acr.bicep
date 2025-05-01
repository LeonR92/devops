@description('The globally unique name for the Azure Container Registry. Must be alphanumeric, 5-50 chars.')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}' // Generates a unique name 

@description('The Azure region where the Container Registry should be deployed.')
param location string = resourceGroup().location
@description('The SKU (pricing tier) for the Container Registry. Basic is the lowest cost tier.')
@allowed([
  'Basic'
])
param acrSku string = 'Basic' // Basic tier

@description('Enable admin user for the Container Registry')
param adminUserEnabled bool = true 


// resource definition
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku 
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrName string = acr.name
output acrId string = acr.id
