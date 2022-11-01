# Running Minecraft on AKS

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
