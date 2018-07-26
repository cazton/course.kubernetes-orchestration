Cazton : Microservice Course : Orchestration: Provisioning
# Kube State Metrics

[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/kube-state-metrics


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName kube-state-metrics -CloudProvider aws
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName kube-state-metrics -CloudProvider aws
```

### Helm

#### Install
``` powershell
helm install stable/kube-state-metrics `
    -f values-int.yaml `
    --namespace default `
    --name kube-state-metrics
```

#### Uninstall

``` powershell
helm delete kube-state-metrics --purge
```

---
