# Minecraft on AKS - Troubleshooting

## Errors

These are problems i've experienced running Minecraft on AKS.

### konnectivity-agent scheduling / node unreachable

The node was not in a healthy state. As a 1 node cluster, the service was unavailable until the node was rebooted. To mitigate against the downtime, 2 nodes should have been deployed.

```
NAMESPACE     NAME                                  READY   STATUS        RESTARTS   AGE
kube-system   ama-logs-8gj22                        2/2     Running       0          5d4h
kube-system   ama-logs-rs-54b8874476-4kq4n          1/1     Running       0          5d4h
kube-system   azure-ip-masq-agent-t54vs             1/1     Running       0          5d4h
kube-system   cloud-node-manager-xnq46              1/1     Running       0          5d4h
kube-system   coredns-autoscaler-5589fb5654-r4nck   1/1     Running       0          5d4h
kube-system   coredns-b4854dd98-9sghx               1/1     Running       0          5d4h
kube-system   coredns-b4854dd98-cwcgr               1/1     Running       0          5d4h
kube-system   csi-azuredisk-node-gmwqv              3/3     Running       0          5d4h
kube-system   csi-azurefile-node-4k7rd              3/3     Running       0          5d4h
kube-system   konnectivity-agent-56c579674d-qm4mg   0/1     Pending       0          11h
kube-system   konnectivity-agent-789456b8bd-p9d2z   1/1     Terminating   0          5d4h
kube-system   konnectivity-agent-789456b8bd-vj6ck   1/1     Running       0          5d4h
kube-system   kube-proxy-cqnd6                      1/1     Running       0          5d4h
kube-system   metrics-server-f77b4cd8-cmkj8         1/1     Running       0          5d4h
kube-system   metrics-server-f77b4cd8-x2lzf         1/1     Running       0          5d4h
minecraft     minecraftg-7f97567976-hrvrn           1/1     Running       0          4d11h
```

```
NAMESPACE     LAST SEEN   TYPE      REASON             OBJECT                                    MESSAGE
kube-system   15m         Warning   FailedScheduling   pod/konnectivity-agent-56c579674d-qm4mg   0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/unreachable: }, that the pod didn't tolerate.
```

> Error from server (ServiceUnavailable): the server is currently unable to handle the request (get pods.metrics.k8s.io)
