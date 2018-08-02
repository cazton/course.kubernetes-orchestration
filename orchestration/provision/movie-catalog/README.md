Cazton : Microservice Course : Orchestration: Provisioning
# Movie Catalog

Demo microservice from the course *Docker Fundamentals* and *Docker Deployment Concepts*
---

## Helm Chart

This service uses the **built-in** chart [`dnc-service`](../../charts/dnc-service)


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName movie-catalog -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName movie-catalog -Environment dev
```

### Helm

#### Install
``` powershell
helm install ../../charts/dnc-service `
    -f values-int.yaml `
    --namespace default `
    --name movie-catalog
```

#### Uninstall

``` powershell
helm delete movie-catalog --purge
```

---
