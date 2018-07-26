Cazton : Microservice Course : Orchestration: Provisioning
# Prometheus

[Redis](http://redis.io/) is an advanced key-value cache and store.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/redis

---

## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName redis -CloudProvider aws
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName redis -CloudProvider aws
```

### Helm

#### Install
``` powershell
helm install stable/redis `
    -f values-int.yaml `
    --namespace default `
    --name redis
```

#### Uninstall

``` powershell
helm delete redis --purge
```

---
