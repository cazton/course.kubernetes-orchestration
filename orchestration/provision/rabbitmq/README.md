Cazton : Microservice Course : Orchestration: Provisioning
# Rabbit MQ 

[Rabbit MQ](https://www.rabbitmq.com) is an open source message broker software (sometimes called message-oriented middleware) that originally implemented the Advanced Message Queuing Protocol (AMQP) and has since been extended with a plug-in architecture to support Streaming Text Oriented Messaging Protocol (STOMP), Message Queuing Telemetry Transport (MQTT), and other protocols.

---

## Helm Chart

https://github.com/helm/charts/tree/master/stable/rabbitmq


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName rabbitmq-ha -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName rabbitmq-ha -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/rabbitmq `
    -f values-int.yaml `
    --namespace default `
    --name rabbitmq
```

#### Uninstall

``` powershell
helm delete rabbitmq --purge
```

---
