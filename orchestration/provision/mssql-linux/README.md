Cazton : Microservice Course : Orchestration: Provisioning
# Microsoft SQL Server

[MS SQL Server](https://www.microsoft.com/en-us/sql-server/) is a relational database management system developed by Microsoft.

> This chart requires at least **2GB of RAM** (3.25 GB prior to 2017-CU2). Make sure to assign enough memory to the Docker VM if you're running on Docker for Mac or Windows.

---

## Helm Chart

https://github.com/helm/charts/tree/master/stable/mssql-linux


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName mssql-linux -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName mssql-linux -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/mssql-linux `
    -f values-int.yaml `
    --namespace default `
    --name mssql-linux
```

#### Uninstall

``` powershell
helm delete mssql-linux --purge
```

---
