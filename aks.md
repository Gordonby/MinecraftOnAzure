# Running Minecraft on AKS

The Azure Kubernetes Service is a managed compute platform for running orchestrating containers. It is a lot more complex that some of the other Azure services for hosting container workloads, so is best suited when you already use AKS or have a strong preference to Kubernetes as an orchestrator.

## Creating the cluster

AKS Construction is a tool for accelerating AKS environment deployment. The link below takes you to the tool, using a preset configuration optimised for Minecraft.

https://azure.github.io/AKS-Construction/?ops=none&secure=low&deploy.clusterName=kubegeneral&deploy.rg=akspersist&cluster.vmSize=Standard_B2s&addons.monitor=aci&cluster.enable_aad=true&cluster.AksDisableLocalAccounts=false&deploy.location=WestEurope&cluster.agentCount=1

## Picking the right VM compute node

I started off using the `Standard_B2s` VM size, with a cluster size of 1 node.

Having a cluster size of 1 makes sense because the system pods really don't take a lot of resource, and Minecraft can't run on multiple replicas.

![image](https://user-images.githubusercontent.com/17914476/199238554-6e326c80-ab89-4cd7-8240-46e43332ea4b.png)

### Memory Contention.

Even though the node still has 1GB of free memory, i was finding that i was getting low memory reports on the node itself which led to Minecraft being restarted.

> minecraft     3m26s       Warning   Evicted                     pod/minecraftg-fdf76df5c-r4nkh          The node was low on resource: memory. Container minecraft was using 1924152Ki, which exceeds its request of 0.
minecraft     3m26s       Normal    Killing                     pod/minecraftg-fdf76df5c-r4nkh          Stopping container minecraft
minecraft     3m16s       Warning   FailedScheduling            pod/minecraftg-fdf76df5c-xtl62          0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/memory-pressure: }, that the pod didn't tolerate.
minecraft     70s         Warning   FailedScheduling            pod/minecraftg-fdf76df5c-xtl62          0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/memory-pressure: }, that the pod didn't tolerate.
minecraft     3m17s       Normal    SuccessfulCreate            replicaset/minecraftg-fdf76df5c         Created pod: minecraftg-fdf76df5c-xtl62

![image](https://user-images.githubusercontent.com/17914476/199239005-49284bf8-0e70-4a55-8408-a225ff8a20ed.png)


### Boosting the VM size

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

Using Container Insights through Azure Monitor is a great way to capture both container and cluster logs. However the pods needed for monitoring do require significant resources, so if logging is not a priority then it can be disabled.

![image](https://user-images.githubusercontent.com/17914476/199448459-33bd1181-fc2f-4bc3-949c-a0ae9e0cdf29.png)

## More node problems

```
kubectl describe nodes
Name:               aks-npsystem-38920627-vmss000006
Roles:              agent

  Type                          Status    LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------    -----------------                 ------------------                ------                          -------
  KubeletProblem                False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   KubeletIsUp                     kubelet service is up
  FreezeScheduled               False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoFreezeScheduled               VM has no scheduled Freeze event
  FrequentDockerRestart         False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoFrequentDockerRestart         docker is functioning properly
  FrequentUnregisterNetDevice   False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoFrequentUnregisterNetDevice   node is functioning properly
  TerminateScheduled            False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoTerminateScheduled            VM has no scheduled Terminate event
  KernelDeadlock                False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   KernelHasNoDeadlock             kernel has no deadlock
  FrequentContainerdRestart     False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoFrequentContainerdRestart     containerd is functioning properly
  RedeployScheduled             False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoRedeployScheduled             VM has no scheduled Redeploy event
  FrequentKubeletRestart        False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoFrequentKubeletRestart        kubelet is functioning properly
  PreemptScheduled              False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:57 +0000   NoPreemptScheduled              VM has no scheduled Preempt event
  ContainerRuntimeProblem       False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   ContainerRuntimeIsUp            container runtime service is up
  RebootScheduled               False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   NoRebootScheduled               VM has no scheduled Reboot event
  VMEventScheduled              False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:56 +0000   NoVMEventScheduled              VM has no scheduled event
  FilesystemCorruptionProblem   False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   FilesystemIsOK                  Filesystem is healthy
  ReadonlyFilesystem            False     Wed, 09 Nov 2022 00:02:07 +0000   Tue, 08 Nov 2022 13:40:06 +0000   FilesystemIsNotReadOnly         Filesystem is not read-only
  MemoryPressure                Unknown   Tue, 08 Nov 2022 23:57:38 +0000   Wed, 09 Nov 2022 00:03:11 +0000   NodeStatusUnknown               Kubelet stopped posting node status.
  DiskPressure                  Unknown   Tue, 08 Nov 2022 23:57:38 +0000   Wed, 09 Nov 2022 00:03:11 +0000   NodeStatusUnknown               Kubelet stopped posting node status.
  PIDPressure                   Unknown   Tue, 08 Nov 2022 23:57:38 +0000   Wed, 09 Nov 2022 00:03:11 +0000   NodeStatusUnknown               Kubelet stopped posting node status.
  Ready                         Unknown   Tue, 08 Nov 2022 23:57:38 +0000   Wed, 09 Nov 2022 00:03:11 +0000   NodeStatusUnknown               Kubelet stopped posting node status.

  Namespace                   Name                                   CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                   ------------  ----------  ---------------  -------------  ---
  kube-system                 ama-logs-8ztvx                         150m (7%)     1 (52%)     550Mi (10%)      1774Mi (33%)   31h
  kube-system                 ama-logs-rs-54b8874476-bkcc9           150m (7%)     1 (52%)     250Mi (4%)       1Gi (19%)      31h
  kube-system                 azure-ip-masq-agent-z5nvw              100m (5%)     500m (26%)  50Mi (0%)        250Mi (4%)     31h
  kube-system                 cloud-node-manager-hd6cv               50m (2%)      0 (0%)      50Mi (0%)        512Mi (9%)     31h
  kube-system                 coredns-autoscaler-5589fb5654-79stc    20m (1%)      200m (10%)  10Mi (0%)        500Mi (9%)     31h
  kube-system                 coredns-b4854dd98-4b5z9                100m (5%)     3 (157%)    70Mi (1%)        500Mi (9%)     31h
  kube-system                 coredns-b4854dd98-vlk9l                100m (5%)     3 (157%)    70Mi (1%)        500Mi (9%)     31h
  kube-system                 csi-azuredisk-node-nlvwb               30m (1%)      0 (0%)      60Mi (1%)        400Mi (7%)     31h
  kube-system                 csi-azurefile-node-dffn5               30m (1%)      0 (0%)      60Mi (1%)        600Mi (11%)    31h
  kube-system                 konnectivity-agent-56c579674d-n57sg    20m (1%)      1 (52%)     20Mi (0%)        1Gi (19%)      31h
  kube-system                 konnectivity-agent-56c579674d-xj5gt    20m (1%)      1 (52%)     20Mi (0%)        1Gi (19%)      31h
  kube-system                 kube-proxy-t9wvt                       100m (5%)     0 (0%)      0 (0%)           0 (0%)         31h
  kube-system                 metrics-server-f77b4cd8-9rcv7          44m (2%)      1 (52%)     55Mi (1%)        2000Mi (37%)   31h
  kube-system                 metrics-server-f77b4cd8-khcgv          44m (2%)      1 (52%)     55Mi (1%)        2000Mi (37%)   31h
  minecraft                   minecraftg-7f97567976-t8k77            500m (26%)    2 (105%)    2000Mi (37%)     3000Mi (55%)   31h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                1458m (76%)   14700m (773%)
  memory             3320Mi (61%)  15108Mi (281%)
  ephemeral-storage  0 (0%)        0 (0%)
  hugepages-1Gi      0 (0%)        0 (0%)
  hugepages-2Mi      0 (0%)        0 (0%)
```
