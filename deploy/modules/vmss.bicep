param uniqueName string
param location string
param artifactUrl string
param subnetId string
param backendPoolId string
param vmSku string = 'Standard_B1s'
param vmUsername string = 'chaos'
param vmPassword string = newGuid()

var vmssScriptTemplate = loadTextContent('../scripts/vm-setup.sh')
var vmssScript = base64(replace(vmssScriptTemplate, '{{{ArtifactURL}}}', artifactUrl))

resource VMSS 'Microsoft.Compute/virtualMachineScaleSets@2021-03-01' = {
  name: uniqueName
  location: location
  sku: {
    name: vmSku
    capacity: 4
  }
  properties: {
    overprovision: false
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk:{
            storageAccountType: 'Premium_LRS'
          }
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'canonical'
          offer: '0001-com-ubuntu-server-focal'
          sku: '20_04-lts-gen2'
          version: 'latest'
      }
      }
      osProfile: {
        computerNamePrefix: 'chaosvmss'
        adminUsername: vmUsername
        adminPassword: vmPassword
      }
      extensionProfile:{
        extensions:[
          {
            name: 'CustomScript'
            properties:{
              type: 'CustomScript'
              publisher: 'Microsoft.Azure.Extensions'
              typeHandlerVersion: '2.0'
              autoUpgradeMinorVersion: true
              settings: {
                script: vmssScript
              }
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${uniqueName}-nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                    applicationGatewayBackendAddressPools: [
                      {
                        id: backendPoolId
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output vmssName string = VMSS.name
