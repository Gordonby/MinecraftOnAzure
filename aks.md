# Running Minecraft on AKS

The Azure Kubernetes Service is a managed compute platform for running orchestrating containers. It is a lot more complex that some of the other Azure services for hosting container workloads, so is best suited when you already use AKS or have a strong preference to Kubernetes as an orchestrator.

## Creating the cluster

https://azure.github.io/AKS-Construction/?ops=none&secure=low&deploy.clusterName=kubegeneral&deploy.rg=akspersist&cluster.vmSize=Standard_B2s&addons.monitor=aci&cluster.enable_aad=true&cluster.AksDisableLocalAccounts=false&deploy.location=WestEurope&cluster.agentCount=1

## Picking the right node

I started off using the `Standard_B2s` VM size, with a cluster size of 1 node.

Having a cluster size of 1 makes sense because the system pods really don't take a lot of resource, and Minecraft can't run on multiple replicas.

![image](https://user-images.githubusercontent.com/17914476/199238554-6e326c80-ab89-4cd7-8240-46e43332ea4b.png)



## Memory Contention.

Even though the node still has 1GB of free memory, i was finding that i was getting low memory reports on the node itself which led to Minecraft being restarted.

> minecraft     3m26s       Warning   Evicted                     pod/minecraftg-fdf76df5c-r4nkh          The node was low on resource: memory. Container minecraft was using 1924152Ki, which exceeds its request of 0.
minecraft     3m26s       Normal    Killing                     pod/minecraftg-fdf76df5c-r4nkh          Stopping container minecraft
minecraft     3m16s       Warning   FailedScheduling            pod/minecraftg-fdf76df5c-xtl62          0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/memory-pressure: }, that the pod didn't tolerate.
minecraft     70s         Warning   FailedScheduling            pod/minecraftg-fdf76df5c-xtl62          0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/memory-pressure: }, that the pod didn't tolerate.
minecraft     3m17s       Normal    SuccessfulCreate            replicaset/minecraftg-fdf76df5c         Created pod: minecraftg-fdf76df5c-xtl62

![image](https://user-images.githubusercontent.com/17914476/199239005-49284bf8-0e70-4a55-8408-a225ff8a20ed.png)


## Boosting the VM size

Given the memory problem, it was time to recreate with more horsepower.

I chose the `Standard_B2ms` because it has double the memory available.

![image](https://user-images.githubusercontent.com/17914476/199243722-ae19668b-e819-4bf3-be12-7bb6f337e2f5.png)

Sizing up nodes isn't supported, so i recreated the cluster.

```bash
# Deploy template with in-line parameters
az deployment group create -g akspersist  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.2/main.json --parameters \
	resourceName=kubegeneral \
	location=westeurope \
	JustUseSystemPool=true \
	agentVMSize=Standard_B2ms \
	agentCount=1 \
	enable_aad=true \
	enableAzureRBAC=true \
	adminPrincipalId=$(az ad signed-in-user show --query id --out tsv) \
	omsagent=true \
	retentionInDays=30
```

## Azure Monitor

![image](https://user-images.githubusercontent.com/17914476/199448459-33bd1181-fc2f-4bc3-949c-a0ae9e0cdf29.png)
