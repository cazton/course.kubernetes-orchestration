Cazton : Microservice Course : Orchestration: Provisioning
# Nginx Ingress

[Nginx](https://www.nginx.com)-ingress is an Ingress controller that uses ConfigMap to store the nginx configuration. 

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName nginx -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName nginx -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/nginx-ingress `
    -f values-int.yaml `
    --namespace default `
    --name nginx
```

#### Uninstall

``` powershell
helm delete nginx --purge
```

---

## Service / Pod Configuration

Service ingress should include the following tag to allow *nginx* to discover and publish the endpoint:

```
kubernetes.io/ingress.class: nginx
```

---
