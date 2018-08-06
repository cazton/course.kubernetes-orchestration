Cazton : Microservice Course : Orchestration: Provisioning
# OpenVPN Server

Installs an [OpenVPN](https://openvpn.net) server inside a kubernetes cluster. New certificates are generated on install, and a script is provided to generate client keys as needed. The chart will automatically configure dns to use kube-dns and route all network traffic to kubernetes pods and services through the vpn. By connecting to this vpn a host is effectively inside a cluster's network.

---

## Helm Chart

https://github.com/kubernetes/charts/tree/master/stable/openvpn


## Installation 

This chart can be installed manually or by using the *project-tasks* script.

#### Install

```powershell
./scripts/project-tasks.ps1 -ProvisionService -ServiceName openvpn -Environment dev
```

#### Uninstall

```powershell
./scripts/project-tasks.ps1 -DestroyService -ServiceName openvpn -Environment dev
```

### Helm

#### Install
``` powershell
helm install stable/openvpn `
    -f values-int.yaml `
    --namespace default `
    --name openvpn
```

#### Uninstall

``` powershell
helm delete openvpn --purge
```

---

## VPN Key Generation

```bash
    KEY_NAME=client
    NAMESPACE=default
    HELM_RELEASE=openvpn
    POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
    echo -e "Pod Name: $POD_NAME"

    SERVICE_NAME=$(kubectl get svc -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
    echo -e "Service Name: $SERVICE_NAME"

    SERVICE_IP=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o go-template='{{range $k, $v := (index .status.loadBalancer.ingress 0)}}{{$v}}{{end}}')
    echo -e "Service IP: $SERVICE_IP"

    kubectl -n "$NAMESPACE" exec -it "$POD_NAME" /etc/openvpn/setup/newClientCert.sh "$KEY_NAME" "$SERVICE_IP"
    kubectl -n "$NAMESPACE" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > $SCRIPT_DIR/keys/$KEY_NAME.ovpn

```
