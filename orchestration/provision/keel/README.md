Cazton : Microservice Course : Orchestration: Provisioning
# Keel

[Keel](https://keel.sh) is a Kubernetes Operator to automate Helm, DaemonSet, StatefulSet & Deployment updates.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/keel


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName keel -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName keel -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/keel `
    -f values-int.yaml `
    --namespace default `
    --name keel
```

#### Uninstall

``` powershell
helm delete keel --purge
```

---
