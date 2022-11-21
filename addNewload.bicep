param location string = 'eastus'
param applicationGatewayName string = 'agw-${location}-01'

param workloadName string = 'app01'

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-${applicationGatewayName}', 'AgwSubnet')
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'pip-agwFE-01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', 'pip-${applicationGatewayName}')
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 5 
    }

    //load
    backendAddressPools: [
      {
        name: 'be-${workloadName}' 
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'settingHttp-${workloadName}'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'lisHttp-${workloadName}' 
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'pip-${applicationGatewayName}')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'ruleHttp-${workloadName}' 
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'lisHttp-${workloadName}')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'be-${workloadName}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'settingHttp-${workloadName}')
          }
          priority: 501
        }
      }
    ]
  }
}
