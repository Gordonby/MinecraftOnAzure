# Minecraft On Azure

This repo provides assets to run Minecraft on Azure

## Considerations

### Data

It's super important that data is backed up regularly when running your Minecraft server. The service most suited to this is the Azure Storage Account. Azure Storage Accounts have a mature set of features for the management of file backups, and can be used in a wide variety of compute platforms. They aren't particuarly well suited to super high throughput, so depending on the number of players you may find the storage a bottleneck at a certain point.

### Compute

### Networking

UDP

## Deployment Asssets

Config | Method | Link
------ | ------ | ----
ACI | Azure CLI | 
AKS | Bicep |
