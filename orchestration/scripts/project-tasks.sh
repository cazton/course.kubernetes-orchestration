#!/bin/bash

#
# Orchestrates the platform services
# Author: Christopher Town - chris@cdinc.net
#


# #############################################################################
# GLOBAL VARIABLES 
#
provider="local"
environment="dev"
hostsfile="/etc/hosts"
hostsip=127.0.0.1
namespace="default"
serviceName=""


# #############################################################################
# CONSTANTS
#
BLUE="\033[0094m"
GREEN="\033[0092m"
RED="\033[0031m"
RESTORE="\033[0m"
YELLOW="\033[0093m"
ROOT_DIR=$(dirname $PWD)
WORKING_DIR=$ROOT_DIR/orchestration


# #############################################################################
# COMMANDS
# #############################################################################


# #############################################################################
# Dashboard
#
dashboard () {
    
    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "+ Launching Kubernetes Dashboard                " 
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "${RESTORE}"

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    if [ "$(yq r ./provision/provision.yaml environments.${environment})" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    provider=$(yq r ./provision/provision.yaml environments.${environment}.provider)
    case "$provider" in
        "aws")
            cd ./kubernetes/aws
            open "http://localhost:8001/api/v1/namespaces/default/services/https:kubernetes-dashboard:/proxy/"
            kubectl proxy 
            ;;
        "azure")
            cd ./kubernetes/azure
            local command=$(terraform output dashboard_command)
            cd $WORKING_DIR
            eval $command
            ;;
        "local")
            open "http://localhost:8001/api/v1/namespaces/default/services/https:kubernetes-dashboard:/proxy/"
            kubectl proxy 
            ;;
        *)
            echo -e "${RED}Unknown Cloud Provider '$provider' ${RESTORE}" 
            exit 1
            ;;
    esac

}


# #############################################################################
# Deploy Cluster
#
deployCluster () {

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "+ Deploying Kubernetes Cluster                  " 
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "${RESTORE}"

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    if [ "$(yq r ./provision/provision.yaml environments.${environment})" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    provider=$(yq r ./provision/provision.yaml environments.${environment}.provider)
    case "$provider" in
        "aws")
            deployAWSCluster
            ;;
        "azure")
            deployAzureCluster
            ;;     
        "local")
            echo -e "${YELLOW}You cannot deploy a 'local' cluster with this tool '$provider' ${RESTORE}" 
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown Cloud Provider '$provider'${RESTORE}" 
            exit 1
            ;;
    esac

}


# #############################################################################
# Deploy AWS Cluster
#
deployAWSCluster () {

    echo -e "${YELLOW}Deploying cluster to AWS ${RESTORE}" 
    echo -e "${YELLOW}Environment ${environment}"

    cd ./kubernetes/aws

    if [ ! -b "./.terraform" ]; then
        terraform init
    fi

    # apply changes
    if [ -z $autoApprove ]; then
        terraform apply -var="env=${environment}"  
    else
        terraform apply -var="env=${environment}" -auto-approve
    fi

    if [ $? -eq 0 ]; then  # did not cancel

        # assign ~/.kube/config credentials
        local server=$(terraform output host) 
        local clusterName=$(terraform output cluster_name)
        
        if [ -z "$clusterName" ]; then
            echo "${YELLOW}Unable to determine cluster name. Please set kubectl context manually${RESTORE}"
            exit 1
        fi

        # terraform output cluster_ca_certificate > ./.aws/cluster_ca
        # kubectl config set-cluster $clusterName --server=$server --certificate-authority="./.aws/cluster_ca" --embed-certs=true
        # kubectl config set-context $clusterName --user=clusterUser_aws --cluster=$clusterName

        # load context
        # ensureContext

        # terraform output config-map-aws-auth > "./.aws/config-map-aws-auth.yaml"
        # kubectl apply -f ./.aws/config-map-aws-auth.yaml
        
        # disable rbac
        # kubectl create clusterrolebinding permissive-binding \
        #     --clusterrole=cluster-admin \
        #     --user=admin \
        #     --user=kubelet \
        #     --group=system:serviceaccounts
        
        # provision helm
        # echo -e "${YELLOW}Provisioning Helm${RESTORE}" 
        # helm init

    fi

    cd $WORKING_DIR
}


# #############################################################################
# Deploy Azure Cluster
#
deployAzureCluster () {

    echo -e "${YELLOW}Deploy to Azure${RESTORE}" 

    cd ./kubernetes/azure

    if [ ! -f "user.tfvars" ]; then
        echo -e "${RED}Please create a user.tfvars file before continuing (see README)${RESTORE}"
        exit 1
    fi

    if [ ! -b "./.terraform" ]; then
        terraform init
    fi

    # apply changes
    if [ -z $autoApprove ]; then
        terraform apply --var-file=user.tfvars 
    else
        terraform apply --var-file=user.tfvars -auto-approve
    fi

    if [ $? -eq 0 ]; then  # did not cancel

        # assign ~/.kube/config credentials
        echo -e "${YELLOW}Configuring kubectl credentials${RESTORE}" 
        local clusterName=$(terraform output cluster_name)
        local resourceGroup=$(terraform output resource_group_name)

        echo -e "${GREEN}Settings credentials for $clusterName cluster ${RESTORE}"
        az aks get-credentials --resource-group $resourceGroup --name $clusterName
        
        # provision helm
        echo -e "${YELLOW}Provisioning Helm${RESTORE}" 
        helm init 

        # dashboard command 
        local dashboardCommand=$(terraform output dashboard_command)

        echo -e "${GREEN}"
        echo -e "Run the following to view the cluster dashboard:"
        echo -e "$dashboardCommand" 
        echo -e "${RESTORE}" ``

    fi

    cd $WORKING_DIR
}




# #############################################################################
# Destroy Cluster
#
destroyCluster () {

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "+ Destroying Kubernetes Cluster                 " 
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "${RESTORE}"

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    if [ "$(yq r ./provision/provision.yaml environments.${environment})" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    provider=$(yq r ./provision/provision.yaml environments.${environment}.provider)
    case "$provider" in
        "aws")
            cd ./kubernetes/aws
            if [ ! -b "./.terraform" ]; then
                terraform init
            fi
            terraform destroy
            ;;
        "azure")
            cd ./kubernetes/azure
            if [ ! -b "./.terraform" ]; then
                terraform init
            fi
            if [ ! -f "user.tfvars" ]; then
                echo -e "${RED}Please create a user.tfvars file before continuing (see README) ${RESTORE}"
                exit 1
            fi
            terraform destroy --var-file=user.tfvars 
            ;;
        "local")
            echo -e "${YELLOW}You cannot destroy a 'local' cluster with this tool '$provider' ${RESTORE}" 
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown Cloud Provider '$provider' ${RESTORE}" 
            exit 1
            ;;
    esac

    cd $WORKING_DIR
}


# #############################################################################
# Automatically configures the .kube config for cloud provider
#
initContext () {

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "+ Initializing Kubectl Context                  "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "${RESTORE}"

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    if [ "$(yq r ./provision/provision.yaml environments.${environment})" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    provider=$(yq r ./provision/provision.yaml environments.${environment}.provider)
    case "$provider" in
        "aws")
            cd ./kubernetes/aws
            
            local server=$(terraform output host) 
            local clusterName=$(terraform output cluster_name)

            terraform output cluster_ca_certificate > ./.aws/cluster_ca
            kubectl config set-cluster $clusterName --server=$server --certificate-authority="./.aws/cluster_ca" --embed-certs=true
            kubectl config set-context $clusterName --user=clusterUser_aws --cluster=$clusterName
            ;;
        "azure")
            cd ./kubernetes/azure

            local clusterName=$(terraform output cluster_name)
            local resourceGroup=$(terraform output resource_group_name)
            if [ -z $clusterName ]; then
                echo -e ""
                echo -e "${RED}Unable to find config in terraform state for $provider ${RESTORE}"
                exit 1
            fi
            az aks get-credentials --resource-group $resourceGroup --name $clusterName
            ;;
        "local")
            echo -e "${YELLOW}You cannot initalize local context with this tool '$provider' ${RESTORE}" 
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown Cloud Provider '$provider' ${RESTORE}" 
            exit 1
            ;;
    esac

    cd $WorkingDir
}


# #############################################################################
# Provision a Service
#
provisionService () {

    local serviceName=$serviceName
    if [ -n "$1" ]; then 
        serviceName=$1
    fi

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    local envconf=$(yq r ./provision/provision.yaml environments.${environment})
    if [ -z "$envconf" ]; then 
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    else
        echo -e "${GREEN}$envconf ${RESTORE}"
    fi

    # service
    local svcconf=$(yq r ./provision/provision.yaml services.${serviceName})
    if [ -z "${svcconf}" ]; then
        echo -e "${RED}Service '$serviceName' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    # description
    local context=$(kubectl config current-context) 
    local chart=$(yq r ./provision/provision.yaml services.${serviceName}.chart)
    local description=$(yq r ./provision/provision.yaml services.${serviceName}.description)
    local namespace=$(yq r ./provision/provision.yaml services.${serviceName}.namespace)
    
    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Provisioning Service                          "
    echo -e "+ $description                                  "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Service: $serviceName                         "
    echo -e "+ Chart: $chart                                 "
    echo -e "+ Context: $context                             "
    echo -e "+ Environment: $environment                     "
    echo -e "+ Namespace: $namespace                         "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"

    if [ ! -d "./provision/$serviceName" ]; then
        echo -e "${RED}Unable to find configuration folder: ./provision/$serviceName ${RESTORE}"
        exit 1
    fi

    # env values override
    valuesFilename="values-$environment.yaml"
    local overrideconf=$(yq r ./provision/provision.yaml environments.${environment}.override)
    if [ ! -z "${overrideconf}" ]; then
        valuesFilename="values-$overrideconf.yaml"
        echo -e "${YELLOW}Overriding values file with: $valuesFilename ${RESTORE}"
    fi

    if [ ! -f "./provision/$serviceName/$valuesFilename" ]; then
        echo -e "${RED}Unable to find configuration file for environment: $valuesFilename ${RESTORE}"
        exit 1
    fi
    
    # prompt approve
    if [ -z $autoApprove ]; then
        read -p "Are you sure you want to proceed (yes|no):" choice
    else
        choice="yes"
    fi

    if [ "$choice" != "yes" ]; then
        echo -e "${RED}Provision Cancelled ${RESTORE}" 
        exit 1
    fi

    if [ -z $imageTag ]; then
        helm upgrade \
            -f "./provision/$serviceName/$valuesFilename" \
            --install \
            --namespace $namespace \
            $serviceName \
            $chart
    else
        helm upgrade \
            -f "./provision/$serviceName/$valuesFilename" \
            --install \
            --namespace $namespace \
            --set image.tag=$imageTag \
            $serviceName \
            $chart
    fi

    # post-deploy manifests
    local postdeploy=$(yq r ./provision/provision.yaml services.${serviceName}.post-deploy[*])
    if [ "$postdeploy" != "null" ]; then
        local prefix="- "
        local manifests=$(echo "$postdeploy" | sed -e "s/^$prefix//") # remove leading '- ' 
        local manifestArr=($manifests)
        for manifest in "${manifestArr[@]}"
        do
            echo -e "${GREEN}Deploying ./provision/$serviceName/$manifest ${RESTORE}" 
            kubectl create -f ./provision/$serviceName/$manifest
        done
    fi
    

    # add hostname
    local hostfile=$(yq r ./provision/provision.yaml environments.${environment}.hostfile) # update hostfile
    local hostname=$(yq r ./provision/provision.yaml environments.${environment}.hostname)
    
    if [ "${hostfile}" != "null" ]; then
        if [ ! -z $hostname ]; then 
            echo -e "${YELLOW}Adding $serviceName.$hostname to $HostsFile ${RESTORE}"
            addhost "$serviceName.$hostname"
        else
            echo -e "${RED}You must define an enviroment hostname to add"
            exit 1
        fi
    fi

}


# #############################################################################
# Provision a Service Group
#
provisionServiceGroup () {

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # group
    local groupconf=$(yq r ./provision/provision.yaml groups.${serviceGroupName})
    if [ "${groupconf}" = "null" ]; then 
        echo -e "${RED}Group '$serviceGroupName' not found in provision.yaml ${RESTORE}"
        exit 1
    fi
    
    local prefix="- "
    local services=$(echo "$groupconf" | sed -e "s/^$prefix//") # remove leading '- ' 
    local servicesArr=($services)

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Provisioning Service Group                    "
    echo -e "+ $serviceGroupName                             "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    for service in "${servicesArr[@]}"
    do
    echo -e "+ $service                                      "
    done
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"

    # prompt approve
    if [ -z $autoApprove ]; then
        read -p "Are you sure you want to proceed (yes|no):" choice
    else
        choice="yes"
    fi

    for service in "${servicesArr[@]}"
    do
        autoApprove=true
        local instance=$service
        provisionService $instance
    done
    


}


# #############################################################################
# Proxy a service
# TODO: Determine if service exposes http before launching browser (cpt)
# 
proxyService () {
    
    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Proxying Service: $serviceName                "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"
    
    local name=$(kubectl get services --selector=app=$serviceName -o jsonpath='{.items..metadata.name}')
    if [ -z $name ]; then
        echo -e "${RED}Service $serviceName not running in cluster ${RESTORE}"
        exit 1
    fi

    if [ -z $hostPort ]; then 
        hostPort=$(jot -r 1  5000 6000) 
    fi
    local servicePort=$(kubectl get services --selector=app=$serviceName -o jsonpath='{.items..spec.ports[0].port}')
    local targetPort=$(kubectl get services --selector=app=$serviceName -o jsonpath={.items..spec.ports[0].targetPort})

    echo -e "${GREEN}Opening http(s)://localhost:$hostPort. Press ctrl-c to cancel...${RESTORE}"

    # launch browser
    if [ ! -z $launch ]; then
        if [ $targetPort = "https" ]; then
            open "https://localhost:$hostPort"
        else
            open "http://localhost:$hostPort"
        fi
    fi

    # forward port
    kubectl port-forward svc/$name $hostPort:$servicePort
}


# #############################################################################
# Uninstall a service
#
removeService () {

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "+ Removing Service: $serviceName                " 
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo -e "${RESTORE}"

    # prompt approve
    if [ -z $autoApprove ]; then
        read -p "Are you sure you want to proceed (yes|no):" choice
    else
        choice="yes"
    fi

    if [ "$choice" != "yes" ]; then
        echo -e "${RED}Remove cancelled ${RESTORE}" 
        exit 1
    fi

    helm delete $serviceName --purge

    # delete hostname
    local hostfile=$(yq r ./provision/provision.yaml environments.${environment}.hostfile) # update hostfile
    local hostname=$(yq r ./provision/provision.yaml environments.${environment}.hostname)

    if [ "${hostfile}" != "null" ]; then
        if [ ! -z $hostname ]; then 
            echo -e "${YELLOW}Adding $serviceName.$hostname to $HostsFile ${RESTORE}"
            removehost "$serviceName.$hostname"
        else
            echo -e "${RED}You must define an enviroment hostname to remove"
            exit 1
        fi
    fi
}


# #############################################################################
# SSH into first pod in service
#
shellService () {

    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Connecting to First Pod in Service            "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"

    echo -e "${RED}Not yet implemented ${RESTORE}"
    exit 1

}


# #############################################################################
# Setup all project depedencies
#
setup () {
    
    echo -e "${GREEN}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Setting Up Environment                        "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"
    
    # yq yaml parse
    brew install yq

    # check provision.yaml
    if [ ! -f "./provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi

    # environment
    if [ "$(yq r ./provision/provision.yaml environments.${environment})" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    provider=$(yq r ./provision/provision.yaml environments.${environment}.provider)
    case "$provider" in
        "aws")
            setupAWS
            ;;
        "azure")
            setupAzure
            ;;     
        "local")
            echo -e "Nothing to setup for local cluster"
            ;;
        *)
            echo -e "${RED}Unknown Cloud Provider '$provider'${RESTORE}" 
            exit 1
            ;;
    esac
}


# #############################################################################
# Setup AWS
#
setupAWS () {

    echo -e "Setting up AWS"

    if [ ! -d ~/.aws ]; then
        mkdir ~/.aws
    fi

    if [ ! -d ~/.aws/heptio ]; then
        mkdir ~/.aws/heptio
    fi

    if [ ! -p ~/.aws/heptio/heptio-authenticator-aws.exe ]; then

        echo -e "${YELLOW}Downloading Heptio IAM Authenticator for AWS ${RESTORE}"
        curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/darwin/amd64/heptio-authenticator-aws \
             -o ~/.aws/heptio/heptio-authenticator-aws
        chmod +x ~/.aws/heptio/heptio-authenticator-aws
        echo -e "${GREEN}Added AWS Heptio Authenticator ${RESTORE}" 
        echo -e "${GREEN}Please add '~/.aws/heptio`` to your user PATH ${RESTORE}" 

    fi
}

# #############################################################################
# HELPER FUNCTIONS
# #############################################################################


# #############################################################################
# Welcome message
#
welcome () {
    
    echo -e "${BLUE}"
    echo -e "                    __              " 
    echo -e "   _________ _____ / /_____  ____   " 
    echo -e "  / ___/ __ \`/_  // __/ __ \/ __ \ " 
    echo -e " / /__/ /_/ / / // /_/ /_/ / / / /  " 
    echo -e " \___/\__,_/ /___\__/\____/_/ /_/   " 
    echo -e "${RESTORE}"
    
}


# #############################################################################
# Finished message
#
finished () {
    
    echo -e "${BLUE}"
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+ Completed "
    echo -e "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "${RESTORE}"
    
}


# #############################################################################
# Ensure the kubectl context is set for provision.yaml environment
#
function ensureContext () {

    # check provision.yaml
    if [ ! -f "${WORKING_DIR}/provision/provision.yaml" ]; then
        echo -e "${RED}Cannot find ./provision/provision.yaml ${RESTORE}"
        exit 1
    fi
    
    # environment
    local envconf=$(yq r ${WORKING_DIR}/provision/provision.yaml environments.${environment})
    if [ "${envconf}" == "null" ]; then
        echo -e "${RED}Environment '$environment' not found in provision.yaml ${RESTORE}"
        exit 1
    fi

    local context=$(yq r ${WORKING_DIR}/provision/provision.yaml environments.${environment}.context)
    if [ "${envconf}" == "null" ]; then
        echo -e "${RED}Context not set for environment '$environment' in provision.yaml ${RESTORE}"
        exit 1
    fi

    local currentContext=$(kubectl config current-context)

    if [ "$currentContext" != "$context" ]; then
        echo -e "${YELLOW}Switching kubectl context to: $context ${RESTORE}"
        kubectl config set-context $context
    else
        echo -e "${YELLOW}Using kubectl context: $context ${RESTORE}"
    fi
}


# #############################################################################
# Adds a host name
# $1    hostname (e.g. service.domain.com)
#
function addhost() {

    local hostname=$1
    local hostsline="$hostsip\t$hostname"

    if [ -n "$(grep $hostname $hostsfile)" ]; then
        echo -e "\n" 
        echo -e "${YELLOW}Host already exists! \n${RESTORE}"
        echo -e "${YELLOW}- $(grep $hostname $hostsfile) ${RESTORE}"
    else
        echo -e "Adding $hostname to your $hostsfile"
        sudo -- sh -c -e "echo '$hostsline' >> $hostsfile"

        if [ -n "$(grep $hostname $hostsfile)" ]; then
            echo -e "${GREEN}$hostname was added succesfully \n $(grep $hostname $hostsfile) ${RESTORE}"
        else
            echo "${RED}Failed to add $hostname, try again! ${RESTORE}"
            exit 1
        fi
    fi
}


# #############################################################################
# Removes a host name
# $1    hostname (e.g. service.domain.com)
#
function removehost() {

    local hostname=$1

    if [ -n "$(grep $hostname $hostsfile)" ]; then
        echo -e "${GREEN}$hostname Found in your $hostsfile, removing now... ${RESTORE}"
        sudo sed -i ".bak" "/$hostname/d" $hostsfile
    else
        echo -e "${YELLOW}$hostname was not found in $hostsfile ${RESTORE}"
    fi
}


# #############################################################################
# Shows the usage for the script.
#
showUsage () {
    
    echo -e "${YELLOW}"
    echo -e "${BLUE}USAGE:${YELLOW}"
    echo -e "   project-tasks.sh [COMMAND] [OPTIONS] [FLAGS]"
    echo -e ""
    echo -e "${BLUE}COMMANDS: ${YELLOW}"
    echo -e "   dashboard                           Proxy the cluster dashboard"
    echo -e "   deploy-cluster                      Deploy kubernetes cluster"
    echo -e "   destroy-cluster                     Remove kubernetes cluster"
    echo -e "   help                                Display help"
    echo -e "   init-context                        Initialize the kubectl context for a given cloud provider."
    echo -e "   provision-service -s=<name>         Provision service to cluster"
    echo -e "   provision-service-group -s=<group>  Provision service to cluster"
    echo -e "   proxy-service -s=<name>             Proxy service in browser"
    echo -e "   remove-service -s=<name>            Remove service from cluster"
    echo -e "   shell-service -s=<name>             SSH into first pod in service"
    echo -e "   setup                               Setup environment for cloud provider"
    echo -e ""
    echo -e "${BLUE}FLAGS: ${YELLOW}"
    echo -e "   --auto-approve                      Run without confirmation prompts"
    echo -e "   --launch                            Launch proxied service in browser"
    echo -e "   --help                              Display help"
    echo -e ""
    echo -e "${BLUE}OPTIONS: ${YELLOW}"
    echo -e "   -e, --environment                   Use environment from provision.yaml"
    echo -e "   -r, --host-port                     Host port when proxing service"
    echo -e "   -s, --service                       The service name to deploy"
    echo -e "   -g, --service-group                 The service group to deploy"
    echo -e "   -i, --image-tag                     The docker repository image tag to use for service provisioning"
    echo -e ""
    echo -e "${BLUE}EXAMPLE: ${YELLOW}"
    echo -e "    project-tasks.sh provision-service --service-name=redis --environment=int"
    echo -e "    project-tasks.sh provision-service -s=redis -e=int"
    echo -e "    project-tasks.sh remove-service -s=redis -e=dev"
    echo -e "    project-tasks.sh proxy-service -s=grafana -e=prod -p=aws"
    echo -e "${RESTORE}"
    
}


# #############################################################################
# EXECUTE
# #############################################################################

set -e # exit on any error

welcome

if [ $# -eq 0 ]; then
    showUsage
else
    # set command
    command=$1
    shift # move next option (skip command)
    
    # options and flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --auto-approve)
                autoApprove=true
                ;;
            --environment=*|-e=*)
                environment="${1#*=}"
                ;;
            --help|-?)
                showUsage
                exit 0
                ;;
            --host-port=*|-r=*)
                hostPort="${1#*=}"
                ;;
            --launch)
                launch=true
                ;;
            --service=*|-s=*)
                serviceName="${1#*=}"
                ;;
            --service-group=*|-g=*)
                serviceGroupName="${1#*=}"
                ;;
            --image-tag=*|-t=*)
                imageTag="${1#*=}"
                ;;
            *)
            echo -e  "${RED}Error: Invalid option $1.${RESTORE}"
            exit 1
        esac
        shift
    done
    
    # run selected command
    case "$command" in
        "dashboard")
            ensureContext
            dashboard 
            ;;
        "deploy-cluster") 
            deployCluster 
            ;;
        "destroy-cluster")
            ensureContext
            destroyCluster  
            ;;
        "init-context")
            initContext  
            ;;
        "provision-service")
            ensureContext
            provisionService
            ;;
        "provision-service-group")
            ensureContext
            provisionServiceGroup
            ;;
        "proxy-service")
            ensureContext
            proxyService
            ;;
        "remove-service")
            ensureContext
            removeService
            ;;
        "shell-service")
            ensureContext
            shellService
            ;;
        "setup")
            setup
            ;;
        *)
            showUsage
            ;;
    esac

    finished
fi


# #############################################################################
