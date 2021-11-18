param uniqueName string
param location string
param subnetId string

var appGwName = uniqueName
var backendPoolName = 'backend'

resource AppGwPIP 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: uniqueName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings:{
      domainNameLabel: toLower(uniqueName)
    }
  }
}

resource AppGw 'Microsoft.Network/applicationGateways@2021-03-01' = {
  name: appGwName
  location: location
  properties:{
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGwIP'
        properties: {
          subnet:{
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'public'
        properties: {
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress: {
            id: AppGwPIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'http'
        properties:{
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
        properties: {
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'dotnet'
        properties:{
          port: 5000
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 5
        }
      }
    ]
    httpListeners:[
      {
        name: 'http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'public')
          }
          frontendPort:{
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'http')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'httptobackend'
        properties:{
          ruleType:'Basic'
          httpListener:{
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'http')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'dotnet')
          }
        }
      }
    ]
  }
}

output backendPoolId string = '${AppGw.id}/backendAddressPools/${backendPoolName}'
output fqdn string = AppGwPIP.properties.dnsSettings.fqdn
