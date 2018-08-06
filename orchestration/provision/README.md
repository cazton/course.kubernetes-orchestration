Cazton : Microservices Training : Orchestration

# Provisioning

### Services

- [Cert-Manager](./cert-manager/README.md)
- [Grafana](./grafana/README.md)
- [Keel](./keel/README.md)
- [Kubernetes Dashboard](./kubernetes-dashboard/README.md)
- [Metrics Server](./metrics-server/README.md)
- [MongoDB](./mongodb/README.md)
- [Nginx Ingress](./nginx-ingress/README.md)
- [Open VPN](./openvpn/README.md)
- [Prometheus](./prometheus/README.md)
- [Redis](./redis/README.md)

## Scripts

Powershell and Bash scripts are provided to help with the orchestration of you cluster. 

```
.\scripts\project-tasks.sh
.\scripts\project-tasks.ps1
```

---

## Deploying a Kubernetes Cluster

Terraform configurations are provided to provision a cluster to environments defined in `provision.yaml`.


### Options

| Name              | PowerShell       | Bash              | Values
|-                  |-                 |-                  |-
| Environment       | -Environment     | -e, --environment | user defined


### Flags

| Name              | PowerShell       | Bash                
|-                  |-                 |-                    
| No Confirmation   | -AutoApprove     | -a, --auto-approve  
               

### Powershell

```
.\scripts\project-tasks.ps1 -ProvisionCluster -Environement <name>
```

### Bash

```
.\scripts\project-tasks.sh provision-cluster --environment=<name>
```

---

## Destroying a Kubernetes Cluster

To completely remove a deployed cluster, run the following:


### Options

| Name              | PowerShell       | Bash                | Values
|-                  |-                 |-                    |-
| Environment       | -Environment     | -e, --environment | user defined

### Flags

| Name              | PowerShell       | Bash                
|-                  |-                 |-                   
| No Confirmation   | -AutoApprove     | -a, --auto-approve               

#### Powershell

```
.\scripts\project-tasks.ps1 -DestroyCluster -Environment <environment>
```

#### Bash

```
.\scripts\project-tasks.sh destroy-cluster --environment=<name>
```

---

## Open Kubernetes Dashboard

You can via the kubernetes dashboard running within the cluster securely. 

### Options

| Name              | PowerShell       | Bash                | Values     
|-                  |-                 |-                    |-           
| Environment       | -Environment     | -e, --environment   | user defined

#### Powershell

```
.\scripts\project-tasks.ps1 -Dashboard -Environment <name> 
```

#### Bash

```
.\scripts\project-tasks.sh dashbaord --environment=<name>
```

---

## Initialize Kubectl Context

You can initialize the kubectl context for a given environment. This is automatically done when you provision a cluster.

### Options

| Name              | PowerShell       | Bash                | Values     
|-                  |-                 |-                    |-           
| Environment       | -Environment     | -e, --environment   | user defined

### Powershell

```
.\scripts\project-tasks.ps1 -InitContext -Environment <name> 
```

### Bash

```
.\scripts\project-tasks.sh init-context --environment=<name> 
```

---

## Provision a Service

You can provision any service defined in `.\provision\provision.yaml`. 

### Options

| Name              | PowerShell       | Bash                | Values            | Default
|-                  |-                 |-                    |-                  |-
| Service Name      | -ServiceName     | -s, --service-name  | user defined      | n/a
| Environment       | -Environment     | -e, --environment   | dev, int, prod    | dev

> You can configure additional environments in `provision.yaml`

### Powershell

```
.\scripts\project-tasks.ps1 -ProvisionService -ServiceName <service> -Environment <env>
```

### Bash

```
.\scripts\project-tasks.sh provision-service --service-name=<service> --environment=<env>
```

---

## Provision a Service Group

You can define groups of services to be deployed together in `.\provision\provision.yaml`. 

### Options

| Name              | PowerShell       | Bash                | Values            | Default
|-                  |-                 |-                    |-                  |-
| Service Group     | -ServiceGroup    | -g, --service-group | user-defined      | n/a
| Environment       | -Environment     | -e, --environment   | dev, int, prod    | dev

### Powershell

```
.\scripts\project-tasks.ps1 -ProvisionServiceGroup -ServiceGroup <group> -Environment <env>
```

### Bash

```
.\scripts\project-tasks.sh provision-service --service-name=<service> --environment=<env>
```

---

## Remove a Service

You can remove any deployed service defined in `.\provision\provision.yaml`. 

### Options

| Name              | PowerShell       | Bash                | Values            | Default
|-                  |-                 |-                    |-                  |-
| Service Name      | -ServiceName     | -s, --service-name  | user defined      | n/a
| Environment       | -Environment     | -e, --environment   | dev, int, prod    | dev

### Flags

| Name              | PowerShell       | Bash                
|-                  |-                 |-                   
| No Confirmation   | -AutoApprove     | -a, --auto-approve           

### Powershell

```
.\scripts\project-tasks.ps1 -RemoveService -ServiceName <service> -Environment <env> 
```

### Bash

```
.\scripts\project-tasks.sh remove-service --service-name=<service> --environment=<env>
```

---

## Proxy a Service

You can proxy (port-forward) a service in the cluster and optionally launch in a web browser.

### Options

| Name              | PowerShell       | Bash                | Values            | Default
|-                  |-                 |-                    |-                  |-
| Service Name      | -ServiceName     | -s, --service-name  | user defined      | n/a
| Environment       | -Environment     | -e, --environment   | dev, int, prod    | dev
| Host Port         | -HostPort        | -r, --host-port     | 0-65535           | random

### Flags

| Name              | PowerShell       | Bash                
|-                  |-                 |-                   
| Open in browser   | -Launch          | -l, --launch             

### Powershell

```
.\scripts\project-tasks.ps1 -ProxyService -ServiceName <service> -Environment <env> -HostPort 8001 -Launch 
```

### Bash

```
.\scripts\project-tasks.sh proxy-service --service-name=<service> --environment=<env> --host-port 8001 --launch
```

---

## Flags

#### Auto Approve

You can disable confirmation prompts with: `-a, --auto-approve`

| Name              | PowerShell       | Bash                |
|-                  |-                 |-                    |
| Auto Approve      | -AutoApprove     | -a, --auto-approve  |


### Usage

```
.\scripts\project-tasks.sh provision-cluster --environment=<name>
```

```
.\scripts\project-tasks.ps1 -ProvisionCluster -Environment <name>
```

---
