param location string = 'CentralUS'
param prefix string = 'ChaosVMSS'
param artifactUrl string = 'https://github.com/ScottHolden/LiveInstanceDemo/releases/download/LiveInstanceDemo/LiveInstanceDemo.tar.gz'

var uniqueName = '${prefix}-${uniqueString(resourceGroup().id, prefix)}'

module Network 'modules/network.bicep' = {
  name: '${deployment().name}-network'
  params: {
    uniqueName: uniqueName
    location: location
  }
}

module AppGw 'modules/appgw.bicep' = {
  name: '${deployment().name}-appgw'
  params: {
    uniqueName: uniqueName
    location: location
    subnetId: Network.outputs.appGwSubnetId
  }
}

module VMSS 'modules/vmss.bicep' = {
  name: '${deployment().name}-vmss'
  params: {
    uniqueName: uniqueName
    location: location
    subnetId: Network.outputs.vmssSubnetId
    backendPoolId: AppGw.outputs.backendPoolId
    artifactUrl: artifactUrl
  }
}

module Chaos 'modules/chaos.bicep' = {
  name: '${deployment().name}-chaos'
  params: {
    uniqueName: uniqueName
    location: location
    vmssName: VMSS.outputs.vmssName
  }
}

output url string = 'http://${AppGw.outputs.fqdn}/'
