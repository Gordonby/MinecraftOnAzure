// @secure()
// param kubeConfig string

param AksName string

param AcceptMinecraftEula bool
param MinecraftVersion string = '1.19.40.02'
param AppLabel string = 'minecraftg'

param StorageAccountName string
param StorageAccountRg string = resourceGroup().name
param StorageShareName string

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-02-preview' existing = {
  name: AksName
}
var aksCred = aks.listClusterAdminCredential().kubeconfigs[0].value

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: StorageAccountName
  scope: resourceGroup(StorageAccountRg)
}

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: aksCred
}

resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: 'minecraft'
  }
}

module minecraft 'minecraft.bicep' = {
  name: '${deployment().name}-minecraft'
  params: {
    AcceptMinecraftEula: AcceptMinecraftEula
    kubeConfig: aksCred
    StorageAccountKey: storage.listKeys().keys[0].value
    StorageAccountName: StorageAccountName
    namespace: namespace.metadata.name
    StorageShareName: StorageShareName
    AppLabel: AppLabel
    MinecraftVersion: MinecraftVersion
  }
}
