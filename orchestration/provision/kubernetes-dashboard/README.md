Cazton : Microservice Course : Orchestration: Provisioning
# Kubernetes Dashboard

[Kubernetes Dashboard](https://github.com/grafana/grafana) is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.
---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/kubernetes-dashboard

## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName kubernetes-dashboard -Environment dev 
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName kubernetes-dashboard -Environment dev 
```

### Helm

#### Install

``` powershell
helm install stable/kubernetes-dashboard `
    -f values-int.yaml `
    --namespace default `
    --name kube-dashboard
```

#### Uninstall

``` powershell
helm delete kube-dashboard --purge
```
