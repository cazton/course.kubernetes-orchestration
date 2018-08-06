Cazton : Microservice Course : Orchestration: Provisioning
# Prometheus

[Prometheus](https://prometheus.io) is a monitoring system and time series database for Kubernetes. It is leveraged by *[Grafana](../grafana/README.md)* to support real-time metrics dashboards of the state of your cluster and services within it.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/prometheus

---

## Persistence

Persistence is disabled by default

---

## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName prometheus -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName prometheus -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/prometheus `
    -f values-int.yaml `
    --namespace default `
    --name prometheus
```

#### Uninstall

``` powershell
helm delete prometheus --purge
```

---
