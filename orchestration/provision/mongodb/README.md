Cazton : Microservice Course : Orchestration: Provisioning
# Mongo DB

[MongoDB](https://www.mongodb.com/) is a cross-platform document-oriented database. Classified as a NoSQL database, MongoDB eschews the traditional table-based relational database structure in favor of JSON-like documents with dynamic schemas, making the integration of data in certain types of applications easier and faster.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/mongodb


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName mongodb -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName mongodb -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/mongodb `
    -f values-int.yaml `
    --namespace default `
    --name mongodb
```

#### Uninstall

``` powershell
helm delete mongodb --purge
```

---
