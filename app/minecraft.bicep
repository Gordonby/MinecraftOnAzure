@secure()
param kubeConfig string

param namespace string
param AcceptMinecraftEula bool
param MinecraftVersion string = '1.19.40.02'
param AppLabel string = 'minecraftg'

param Image string = 'docker.io/itzg/minecraft-bedrock-server:latest'

param StorageAccountName string
param StorageShareName string

@secure()
param StorageAccountKey string

import 'kubernetes@1.0.0' with {
  namespace: namespace
  kubeConfig: kubeConfig
}

resource secret 'core/Secret@v1' = {
  metadata: {
    name: 'minecraft-storage-secret'
  }
  type: 'Opaque'
  data: {
    azurestorageaccountname: base64(StorageAccountName)
    azurestorageaccountkey: base64(StorageAccountKey)
  }
}

resource config 'core/ConfigMap@v1' = {
  metadata: {
    name: 'minecraft-bedrock-env'
    labels: {
      role: 'service-config'
      app: AppLabel
    }
  }
  data: {
    EULA: '"${AcceptMinecraftEula}"'
    VERSION: '"${MinecraftVersion}"'
    GAMEMODE: '"survival"'
    LEVEL_SEED: '"8486214866965744170"'
    TICK_DISTANCE: '"4"'
    DIFFICULTY: '"easy"'
  }
}

resource deployment 'apps/Deployment@v1' = {
  metadata: {
    name: 'minecraft'
  }
  spec: {
    replicas: 1
    selector: {
      matchLabels: {
        app: AppLabel
      }
    }
    template: {
      metadata: {
        labels: {
          app: AppLabel
        }
      }
      spec: {
        containers: [
          {
            name: 'minecraft'
            image: Image
            resources: {
              requests: {
                memory: '2000Mi'
                cpu: '500m'
              }
              limits: {
                memory: '3000Mi'
                cpu: '2000m'
              }
            }
            envFrom: [
              {
                configMapRef: {
                  name: config.metadata.name
                }
              }
            ]
            volumeMounts: [
              {
                name: 'azurefileshare'
                mountPath: '/data'
              }
            ]
            ports: [
              {
                containerPort: 19132
              }
              {
                containerPort: 19133
              }
            ]
          }
        ]
        volumes: [
          {
            name: 'azurefileshare'
            azureFile: {
              secretName: secret.metadata.name
              shareName: StorageShareName
              readOnly: false
            }
          }
        ]
      }
    }
  }
}

resource service 'core/Service@v1' = {
  metadata: {
    name: AppLabel
  }
  spec: {
    ports: [
      {
        port: 19132
        targetPort: 19132
        protocol: 'UDP'
        name: 'mine4'
      }
      {
        port: 19133
        targetPort: 19133
        protocol: 'UDP'
        name: 'mine6'
      }
    ]
    selector: {
      app: AppLabel
    }
  }
}
