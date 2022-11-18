param nameseed string = 'minecraft8'
param createAcr bool = false
param existingContainerRegistryName string = ''
param existingContainerRegistryGroup string = ''
param location string = resourceGroup().location
param imageName string = 'docker.io/itzg/minecraft-bedrock-server:latest'
param storageShareName string = 'myworld'
param uniqueSuffix string = uniqueString(resourceGroup().id, deployment().name)

@description('Creates the file share in Azure storage with daily backup')
module storage 'storage.bicep' = {
  name: '${deployment().name}-storage'
  params: {
    location: location
    nameseed: nameseed
    storageShareName: storageShareName
    uniqueSuffix: uniqueSuffix
  }
}

@description('This module seeds an ACR with the Container image so you are not dependant on an external registry')
module acrImport 'br/public:deployment-scripts/import-acr:3.0.1' = if(createAcr || (!empty(existingContainerRegistryGroup) && !empty(existingContainerRegistryName))) {
  name: '${deployment().name}-acrImportImage'
  scope: createAcr ? resourceGroup() : resourceGroup(existingContainerRegistryGroup)
  params: {
    acrName: createAcr ? acr.name : existingContainerRegistryName
    location: location
    images: array(imageName)
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = if(createAcr) {
  name: 'cr${nameseed}${uniqueSuffix}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output AcrImage string = createAcr || (!empty(existingContainerRegistryGroup) && !empty(existingContainerRegistryName)) ? first(acrImport.outputs.importedImages) : ''
output StorageAccountName string = storage.outputs.AccountName
output StorageShareName string = storage.outputs.ShareName
