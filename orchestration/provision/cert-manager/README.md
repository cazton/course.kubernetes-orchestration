Cazton : Microservice Course : Orchestration: Provisioning
# Cert Manager

[cert-manager](https://github.com/jetstack/cert-manager/) is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/cert-manager

---

## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName cert-manager -CloudProvider aws
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName cert-manager -CloudProvider aws
```

### Helm

#### Install

``` powershell
helm install stable/cert-manager `
    -f values-int.yaml `
    --namespace default `
    --name cert-manager
```

#### Uninstall

``` powershell
helm delete cert-manager --purge
```

### ClusterIssuer

A cluster issuer is required to issue

### Manifests

#### cluster-issuer.yaml

This manifest installs staging and production cluster issuers for [LetsEncrypt](https://letsencrypt.org).

