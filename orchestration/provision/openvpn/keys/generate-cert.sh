#!/bin/bash

#
# Nginx Proxy
#

# #############################################################################
# Settings
#
BLUE="\033[00;94m"
GREEN="\033[00;92m"
RED="\033[00;31m"
RESTORE="\033[0m"
YELLOW="\033[00;93m"
ROOT_DIR=$(dirname $PWD)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# #############################################################################
#
#
generateCert () {

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
    kubectl -n "$NAMESPACE" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > $SCRIPT_DIR/$KEY_NAME.ovpn

}

# #############################################################################
# Shows the usage for the script.
#
showUsage () {

    echo -e "${YELLOW}"
    echo -e "Usage: project-tasks.sh [COMMAND] (ENVIRONMENT)"
    echo -e ""
    echo -e "Commands:"
    echo -e "    generate: Generates a client vpn key certificate"
    echo -e ""
    echo -e "Example:"
    echo -e "    ./project-tasks.sh install"
    echo -e ""
    echo -e "${RESTORE}"

}


# #############################################################################
# Switch parameters
#
if [ $# -eq 0 ]; then
    showUsage
else

    ENVIRONMENT=$(echo -e $2 | tr "[:upper:]" "[:lower:]")
    if [[ -z $ENVIRONMENT ]]; then ENVIRONMENT="dev"; fi

    case "$1" in
        "install")
            install
            ;;
        "remove")
            remove
            ;;
        "generate")
            generate
            ;;
        *)
            showUsage
            ;;
    esac
fi

# #############################################################################
