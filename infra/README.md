# Minecraft infrastructure

- Storage (files)
- (optional) Container Registry

```bash
az deployment group create -g yourRg -f infra/inframain.bicep -p AksName=yourAksClusterName AcceptMinecraftEula=true
```
