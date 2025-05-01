@description('The globally unique name for the Azure Container Registry. Must be alphanumeric, 5-50 chars.')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}' // Generates a unique name by default

@description('The Azure region where the Container Registry should be deployed.')
param location string = resourceGroup().location // Defaults to the resource group's location

@description('The SKU (pricing tier) for the Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Standard' // Standard is a good balance of features and cost

@description('Enable admin user for the Container Registry. For CI/CD, consider using Service Principals or Managed Identity instead.')
param adminUserEnabled bool = true // Set to 'true' for easier initial manual login/push

// Define the Azure Container Registry resource
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: adminUserEnabled // Enables the admin user account (username/password)
  }
}

// Output the FQDN (login server) of the created ACR - needed for 'docker login'
output acrLoginServer string = acr.properties.loginServer
// Output the name of the created ACR
output acrName string = acr.name
// Output the resource ID of the created ACR
output acrId string = acr.id