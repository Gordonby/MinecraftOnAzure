param nameseed string = 'minecraft'
param location string = resourceGroup().location
param storageShareName string = 'myworld'
param AksName string
param AcceptMinecraftEula bool

module infra 'infra/inframain.bicep' = {
  name: '${deployment().name}-infra'
  params: {
    nameseed: nameseed
    location: location
    storageShareName: storageShareName
  }
}

module app 'app/appmain.bicep' = {
  name: '${deployment().name}-app'
  params: {
    AcceptMinecraftEula: AcceptMinecraftEula
    AksName: AksName
    StorageAccountName: infra.outputs.StorageAccountName
    StorageShareName: infra.outputs.StorageShareName
  }
}
