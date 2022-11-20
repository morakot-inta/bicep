param location string
param appServiceAppName string

@allowed([
  'nonprd'
  'prd'
])
param envType string

var appServicePlanName = 'toy-product-launch-plan'
var appServicePlanSkuName = (envType == 'prd') ? 'P2v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku:{
    name: appServicePlanName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties:{
    httpsOnly:true
    serverFarmId: appServicePlan.id
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
