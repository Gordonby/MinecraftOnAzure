param location string = resourceGroup().location
param nameseed string 
param storageShareName string 
param storageDeleteRetentionDays int = 14
param backupEnabled bool = true

@description('Used to reference todays date')
param today string = utcNow('yyyyMMddTHHmmssZ')
param uniqueSuffix string = uniqueString(resourceGroup().id, deployment().name)

var storageName = take('st${toLower(nameseed)}${uniqueSuffix}',24)
var tomorrow = dateTimeAdd(today, 'P1D','yyyy-MM-dd')
var backupTime = '${take(tomorrow,10)}T03:00:00+00:00'

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
  }
  
  resource fileServices 'fileServices' = {
    name: 'default'
    properties: {
      shareDeleteRetentionPolicy: {
        enabled: true
        days: storageDeleteRetentionDays
      }
    }
    resource share 'shares' = {
      name: storageShareName
      properties: {
        accessTier: 'TransactionOptimized' 
      }
    }
  }
}

resource recoveryServiceVault 'Microsoft.RecoveryServices/vaults@2022-09-30-preview' = if(backupEnabled) {
  name: 'bkp-${nameseed}'
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource dailyPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-09-01-preview' = if(backupEnabled) {
  parent: recoveryServiceVault
  name: 'DailyPolicy'
  properties: {
    workLoadType: 'AzureFileShare'
    backupManagementType: 'AzureStorage'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        backupTime
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
         retentionDuration: {
          count: storageDeleteRetentionDays*2
          durationType: 'Days'
         }
         retentionTimes: [
           backupTime
         ]
      }
      weeklySchedule: null
      monthlySchedule: null
      yearlySchedule: null
    }
    timeZone: 'UTC'
  }
}

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2022-09-01-preview' = if(backupEnabled) {
  name: '${recoveryServiceVault.name}/Azure/storagecontainer;Storage;${resourceGroup().name};${storageaccount.name}'
  properties: {
    backupManagementType: 'AzureStorage'
    containerType: 'StorageContainer'
    sourceResourceId: storageaccount.id
    acquireStorageAccountLock: 'Acquire'
  }
}

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
  parent: protectionContainer
  name: 'AzureFileShare;${storageShareName}'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    sourceResourceId: storageaccount.id
    policyId: dailyPolicy.id
    isInlineInquiry: true
  }
}
