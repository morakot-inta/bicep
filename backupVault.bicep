param location string = 'eastasia'

resource backupVault 'Microsoft.DataProtection/backupVaults@2022-10-01-preview' = {
  name: 'bvaultBackupStorage'
  location: location
  identity: {
    type: 'SystemAssigned' 
  }
  properties: {
    storageSettings: [
      {
        datastoreType: 'VaultStore'
        type: 'LocallyRedundant'
      }
    ]
  }
  }
