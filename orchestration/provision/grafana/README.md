Cazton : Microservice Course : Orchestration: Provisioning
# Grafana

[Grafana](https://github.com/grafana/grafana) is an open source, feature rich, metrics dashboard and graph editor for Graphite, Elasticsearch, OpenTSDB, Prometheus and InfluxDB.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/grafana

## Important Configuration Values

You should change the following chart values to suit your needs:

```yaml
- adminUser: admin
- adminPassword: {password}
- ingress:
    - hosts:
        - grafana.domain.com
```

### Persistence

Persistence is disabled by default

```yaml
- persistence:
  enabled: false
  storageClassName: default
```

---

## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName grafana -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName grafana -Environment dev
```

### Helm

#### Install

``` powershell
helm install stable/grafana `
    -f values-int.yaml `
    --namespace default `
    --name grafana
```

#### Uninstall

``` powershell
helm delete grafana --purge
```

---

## Default Dashboards

The following dashboards have been configured by default with this chart:

- [Kubernetes Cluster](https://grafana.com/dashboards/6417)
- [Kubernetes Nodes](https://grafana.com/dashboards/3140)
- [Kubernetes Pods](https://grafana.com/dashboards/6336)
- [Prometheus Redis](https://grafana.com/dashboards/763)
