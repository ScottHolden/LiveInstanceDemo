param uniqueName string
param location string

var appGwSubnetName = 'AppGw'
var vmssSubnetName = 'VMSS'

resource VNet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: uniqueName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.22.190.0/24'
      ]
    }
    subnets: [
      {
        name: appGwSubnetName
        properties: {
          addressPrefix: '172.22.190.0/25'
        }
      }
      {
        name: vmssSubnetName
        properties: {
          addressPrefix: '172.22.190.128/25'
        }
      }
    ]
  }
}

output appGwSubnetId string = '${VNet.id}/subnets/${appGwSubnetName}'
output vmssSubnetId string = '${VNet.id}/subnets/${vmssSubnetName}'
