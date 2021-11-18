param uniqueName string
param location string
param vmssName string

var selectorId = guid(uniqueName)
var vmContributorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource VMSS 'Microsoft.Compute/virtualMachineScaleSets@2021-07-01' existing = {
  name: vmssName
}

// Enable our VMSS as a Chaos Studio target
resource Target 'Microsoft.Chaos/targets@2021-09-15-preview' = {
  name: 'microsoft-virtualmachinescaleset'
  scope: VMSS
  properties: {}
}

// Enable the shutdown VMSS action
resource ShutdownAction 'Microsoft.Chaos/targets/capabilities@2021-09-15-preview' = {
  name: 'Shutdown-1.0'
  parent: Target
  properties: {}
}

// Build our experiment
resource ShutdownExperiment 'Microsoft.Chaos/experiments@2021-09-15-preview' = {
  name: '${uniqueName}-Shutdown'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    selectors: [
      {
        type: 'List'
        id: selectorId
        targets: [
          {
            id: Target.id
            type: 'ChaosTarget'
          }
        ]
      }
    ]
    steps: [
      {
        name: 'Shutdown Step'
        branches: [
          {
            name: 'Branch 1'
            actions: [
              {
                name: 'urn:csci:microsoft:virtualMachineScaleSet:shutdown/1.0'
                type: 'continuous'
                selectorId: selectorId
                duration: 'PT1M'
                parameters: [
                  {
                    key: 'abruptShutdown'
                    value: 'true'
                  }
                  {
                    key: 'instances'
                    value: '[1,3]'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

// Setup permissions for experiment
resource VMSSRoleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(Target.id, ShutdownExperiment.id)
  scope: VMSS
  properties: {
    principalId: ShutdownExperiment.identity.principalId
    roleDefinitionId: vmContributorRole
    principalType: 'ServicePrincipal'
  }
}
