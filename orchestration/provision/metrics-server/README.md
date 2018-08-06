Cazton : Microservice Course : Orchestration: Provisioning
# Metrics Server

Starting from Kubernetes 1.8, resource usage metrics, such as container CPU and memory usage, are available in Kubernetes through the [Metrics API](https://kubernetes.io/docs/tasks/debug-application-cluster/core-metrics-pipeline/).

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/metrics-server


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName metrics-server -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName metrics-server -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/metrics-server `
    -f values-int.yaml `
    --namespace default `
    --name metrics-server
```

#### Uninstall

``` powershell
helm delete metrics-server --purge
```

---
