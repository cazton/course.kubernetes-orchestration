<#
.SYNOPSIS
	Orchestrates the platform services
.NOTES  
    File Name  : project-tasks.ps1  
    Author     : Christopher Town - chris@cdinc.net  
.PARAMETER AutoApprove
    Runs commands without user input
.PARAMETER DeployCluster
	Deploys an AWS or Azure K8S Cluster
.PARAMETER DestroyCluster
    Destroys an AWS or Azure K8S Cluster
.PARAMETER HostPort
    The port use when proxing a service (default is random)
.PARAMETER ImageTag
	The docker repository image tag to use for service provisioning
.PARAMETER InitContext
	Initializes context for cloud provider
.PARAMETER Launch
	Launch the proxied service in the browser
.PARAMETER ProvisionService
    Provisions a helm chart service 
.PARAMETER ProvisionServiceGroup
    Provisions a service group
.PARAMETER RemoveService
    Removes a helm chart service 
.PARAMETER Namespace
    The k8S namespace used for deploying services 
.PARAMETER ProxyService
	Proxies a service in the cluster with port forwarding
.PARAMETER ServiceName
	The service name from provision.yaml to deploy
.PARAMETER ServiceInstance
	The service instance name (for multi service deployments) (e.g. rabbit-mq-discovery)
.PARAMETER ServiceGroupName
	The service group from provision.yaml to deploy
.PARAMETER ShellService
	Creates an SSH shell to first pod in service deployment
.PARAMETER Setup
	Setup AWS or Azure dependencies
.PARAMETER Environment
	The environment to build from provision.yaml, defaults to dev
.EXAMPLE
	C:\PS> .\project-tasks.ps1 -ProvisionService -ServiceName nginx-ingress -Environment int
#>


# #############################################################################
# Params (switch params is last method in script)
#
[CmdletBinding(PositionalBinding = $false)]
Param(
    # Commands
    [Switch]$Dashboard,
    [Switch]$DeployCluster,
    [Switch]$DestroyCluster,
    [Switch]$InitContext,
    [Switch]$ProvisionService,
    [Switch]$ProvisionServiceGroup,
    [Switch]$ProxyService,
    [Switch]$RemoveService,
    [Switch]$ShellService,
    [Switch]$Setup,
    # Flags
    [Switch]$AutoApprove,
    [Switch]$Launch,
    # Options
    [String]$Environment = "dev",
    [String]$ImageTag = "",
    [String]$Namespace = "default",
    [String]$HostPort,
    [String]$ServiceGroupName = "development",
    [String]$ServiceInstance = "",
    [String]$ServiceName = ""
)


# #############################################################################
# GLOBAL VARIABLES 
#
$HostsFile      = "C:\Windows\System32\drivers\etc\hosts"
$HostsIP        = "127.0.0.1"
$ProjectDir     = (Get-Item -Path "..\" -Verbose).FullName
$StartTime      = $(Get-Date)
$WorkingDir     = (Get-Item -Path ".\" -Verbose).FullName


# #############################################################################
# COMMANDS
# #############################################################################


# #############################################################################
# Provision Cluster (AWS or Azure)
#
Function Dashboard () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Launching Kubernetes Dashboard                " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    $config = GetProvisionConfig

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    }

    switch ( $config.environments.$Environment.Provider )
    {
        "aws"   { cd .\kubernetes\aws }
        "azure" { cd .\kubernetes\azure }     
        "local" {
            $tokenSecret = $(kubectl -n kube-system get secrets | Select-String kubernetes-dashboard |  %{ $_.ToString().split()[0] } | %{ kubectl -n kube-system describe secret $_ })
            Write-Output $tokenSecret
            # $tokenSecret | grep token: | %{ $($_.ToString() -split '\s+')[1] } | clip
            start "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/"
            # kubectl port-forward svc/kube-dashboard-kubernetes-dashboard 8000:8443
            kubectl proxy 
            Exit 0
        }
           
        default { 
            Write-Host "Unknown Cloud Provider '$CloudProvider'" -ForegroundColor "Red"
            Exit 1
        }
    }
    
    $command = terraform output dashboard_command
    cd $WorkingDir

    Invoke-Expression -Command $command
}


# #############################################################################
# Provision Cluster (AWS or Azure)
#
Function DeployCluster () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Deploying Cluster                             " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    $config = GetProvisionConfig

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    } Else {
        Write-Host $config.environments.$Environment.description -ForegroundColor "Green"
    }

    switch ( $config.environments.$Environment.Provider )
    {
        "aws"   { DeployAWSCluster }
        "azure" { DeployAzureCluster }     
        "local" {
            Write-Host "You cannot deploy a 'local' cluster with this tool" -ForegroundColor "Yellow"
            Exit 0
        }
        default { 
            Write-Host "Unknown Cloud Provider '$CloudProvider'" -ForegroundColor "Red"
            Exit 1
        }
    }
}


# #############################################################################
# Deploy AWS Cluster
#
Function DeployAWSCluster () {

    Write-Host "Deploying to AWS..." -ForegroundColor "Yellow"

    cd ./kubernetes/aws

    If (!(Test-Path -Path "./.terraform")) {
        terraform init
    }

    # Apply changes
    If ($AutoApprove) {
        terraform apply -var="env=$environment" -auto-approve 
    } Else {
        terraform apply -var="env=$environment"
    }

    If ($?) { # did not cancel

        # Add cluster and context to kubectl config
        $server = (terraform output host)
        $clusterName = (terraform output cluster_name) 
        terraform output cluster_ca_certificate | Set-Content "./.aws/cluster_ca"
        
        # kubectl config set-cluster $clusterName --server=$server --certificate-authority="./.aws/cluster_ca" --embed-certs=true
        # kubectl config set-context $clusterName --user=clusterUser_aws_$environment --cluster=$clusterName
        
        # Switch context
        # EnsureContext

        # Set config map with node roles to allow joining cluster
        # terraform output config-map-aws-auth | Set-Content "./.aws/config-map-aws-auth.yaml"
        # kubectl apply -f ./.aws/config-map-aws-auth.yaml
  
        # Provision helm
        # Write-Host "Provisioning Helm" -ForegroundColor "Yellow"
        # helm init
    }

    cd $WorkingDir
    
}


# #############################################################################
# Deploy AWS Cluster
#
Function DeployAzureCluster () {

    Write-Host "Deploying to Azure..." -ForegroundColor "Yellow"
    
    cd ./kubernetes/azure

    If (!(Test-Path -Path "./.terraform")) {
        terraform init
    }

    # Apply changes
    If ($AutoApprove) {
        terraform apply -var="env=$environment" -auto-approve 
    } Else {
        terraform apply -var="env=$environment"
    }

    If ($?) { # did not cancel

        # Assign ~/.kube/config credentials
        Write-Host "Configuring kubectl credentials" -ForegroundColor "Yellow"
        $clusterName = terraform output cluster_name
        $resourceGroup = terraform output resource_group_name 
        az aks get-credentials --resource-group $resourceGroup --name $clusterName
        
        # Provision helm
        Write-Host "Provisioning Helm" -ForegroundColor "Yellow"
        helm init

        # Dashboard command 
        $dashboardCommand = terraform output dashboard_command
        Write-Host "" 
        Write-Host "Run the following to view the cluster dashboard:" -ForegroundColor "Yellow"
        Write-Host "$dashboardCommand" -ForegroundColor "Yellow"
        Write-Host "" 
    }    

    cd $WorkingDir
}


# #############################################################################
# Destroy Cluster (AWS or Azure)
#
Function DestroyCluster () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Destroying Cluster                            " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    $config = GetProvisionConfig

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    } Else {
        Write-Host $config.environments.$Environment.description -ForegroundColor "Green"
    }

    switch ( $config.environments.$Environment.Provider )
    {
        "aws"   { cd .\kubernetes\aws }
        "azure" { cd .\kubernetes\azure }     
        "local" {
            Write-Host "You cannot destroy a 'local' cluster with this tool" -ForegroundColor "Yellow"
            Exit 0
        }
        default { 
            Write-Host "Unknown Cloud Provider '$CloudProvider'" -ForegroundColor "Red"
            Exit 1
        }
    }

    If (!(Test-Path -Path "./.terraform")) {
        terraform init
    }

    If ($AutoApprove) {
        terraform destroy -auto-approve
    } Else {
        terraform destroy
    }

    cd $WorkingDir
}


# #############################################################################
# Automatically configures the .kube config for cloud provider
#
Function InitContext () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Initializing Kubectl Context                  " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    $config = GetProvisionConfig

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    } Else {
        Write-Host $config.environments.$Environment.description -ForegroundColor "Green"
    }

    switch ( $config.environments.$Environment.Provider )
    {
        "aws"   { 

         }
        "azure" { 
            
            cd ./kubernetes/azure

            $clusterName = terraform output cluster_name
            $resourceGroup = terraform output resource_group_name
            If (!$clusterName -or !$resourceGroup) {
                Write-Host "Unable to find config in terraform state for $CloudProvider."
                exit 1
            }
            az aks get-credentials --resource-group $resourceGroup --name $clusterName
            
         }     
        "local" {
            Write-Host "You cannot initalize local context with this tool" -ForegroundColor "Yellow"
            Exit 0
        }
        default { 
            Write-Host "Unknown Cloud Provider '$CloudProvider'" -ForegroundColor "Red"
            Exit 1
        }
    }

    cd $WorkingDir
}


# #############################################################################
# Provision a Service
#
Function ProvisionService {

    Param (
        [Parameter(Mandatory=$False)]  [String]$name
    )

    If (![string]::IsNullOrWhitespace($name)){
        $ServiceName = $name
    }

    $config = GetProvisionConfig

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    } Else {
        Write-Host $config.environments.$Environment.description -ForegroundColor "Green"
    } 

    # Service
    If (!($config.services.$ServiceName)) {
        Write-Host "Service '$ServiceName' not found in provision.yaml"
        Exit 1
    }

    # Description
    $context = kubectl config current-context 
    $chart  = $config.services.$ServiceName.chart
    $description  = $config.services.$ServiceName.description
    $namespace = $config.services.$ServiceName.namespace

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Provisioning Service: $ServiceName            " -ForegroundColor "Green"
    Write-Host "+ $description                                  " -ForegroundColor "Green"
    Write-Host "+ Chart: $chart                                 " -ForegroundColor "Green"
    Write-Host "+ Context: $context                             " -ForegroundColor "Green"
    Write-Host "+ Image Tag: $ImageTag                          " -ForegroundColor "Green"
    Write-Host "+ Namespace: $namespace                         " -ForegroundColor "Green"
    Write-Host "+ Environment: $Environment                     " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    If (!(Test-Path -Path "$WorkingDir/provision/$ServiceName")) {
        Write-Host "Unable to find configuration in $WorkingDir/provision/$ServiceName" -ForegroundColor "Red"
        Exit 1        
    }

    # Environment values override
    $valuesFilename = "values-$Environment.yaml"
    $overrideValue = $config.environments.$Environment.override
    If ( $config.environments.$Environment.override ) {
        $valuesFilename = "values-$overrideValue.yaml"
        Write-Host "Overriding values file with: $valuesFilename" -ForegroundColor "Yellow"
    }

    If (!(Test-Path -Path "$WorkingDir/provision/$ServiceName/$valuesFilename")) {
        Write-Host "Unable to find configuration for environment '$valuesFilename'" -ForegroundColor "Red"
        Exit 1        
    }
    
    If (!$AutoApprove) {
        $confirmation = Read-Host "Are you Sure You Want To Proceed (yes|no):"
        If ($confirmation -ne 'yes') {
            Write-Host "Provision Cancelled" -ForegroundColor "Red"
            Exit 1
        }
    }

    # Provision
    If ($ImageTag -ne "") {
        helm upgrade `
            -f "./provision/$ServiceName/$valuesFilename" `
            --install `
            --namespace $namespace `
            --set image.tag=$ImageTag `
            $ServiceName `
            $chart
    }
    Else {
        helm upgrade `
            -f "./provision/$ServiceName/$valuesFilename" `
            --install `
            --namespace $namespace `
            $ServiceName `
            $chart
    }
    
    # Post-provision manifests
    If ($config.services.$ServiceName["post-deploy"]){

        Write-Host "Found Post-Provision Manifests" -ForegroundColor "Yellow"
        Write-Host "Waiting 5 seconds for helm provisioning to complete..." -ForegroundColor "Yellow"
        Start-Sleep -s 5

        Foreach ($manifestPath in $config.services.$ServiceName["post-deploy"]) {
            Write-Host "Provisioning ./provision/$ServiceName/$manifestPath" -ForegroundColor "Green"
            kubectl create -f "./provision/$ServiceName/$manifestPath"
        }
    }

    # Add hostname
    If ($config.environments.$Environment.hostfile) {
        $hostname = $config.environments.$Environment.hostname
        If ($hostname) {
            Write-Host "Adding $serviceName.$hostname to $HostsFile" -ForegroundColor "Yellow"
            AddHost "$serviceName.$hostname"
        } Else {
            Write-Host "You must define an enviroment hostname to add" -ForegroundColor "Red"
            exit 1
        }
    }
}


# #############################################################################
# Provision a Service Group
#
Function ProvisionServiceGroup () {

    $config = GetProvisionConfig

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Provisioning Service Goup: $ServiceGroupName  " -ForegroundColor "Green"
    Write-Host "+                                               " -ForegroundColor "Green"
    Foreach ($service in $config.groups.$ServiceGroupName) {
    Write-Host "+ $service                                      " -ForegroundColor "Green"
    }
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    If (!$AutoApprove) {
        $confirmation = Read-Host "Are you Sure You Want To Proceed (yes|no):"
        If (!($confirmation -eq 'yes')) {
            Write-Host "Provision Group Cancelled" -ForegroundColor "Red"
            Exit 1
        }
    }

    Foreach ($service in $config.groups.$ServiceGroupName) {
        $AutoApprove = $True
        ProvisionService $service 
    }
}


# #############################################################################
# Port-Forward a Service and Open in Browser
#
Function ProxyService () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Proxying Service: $ServiceName                " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""
    
    $name = kubectl get services --selector=app=$ServiceName -o jsonpath="{.items..metadata.name}" 

    If (!$name) {
        Write-Host "Service $ServiceName not running in cluster" -ForegroundColor "Red"
        Exit 1
    } ElseIf ($name.split(' ').Count -gt 1 -and !$ServiceInstance) {
        Write-Host "More than one service found matching service deployment for '$ServiceName'" -ForegroundColor "Red"
        Write-Host "-> $name" -ForegroundColor "Red"
        Write-Host "Please designate the desired instance with -ServiceInstance option" -ForegroundColor "Red"
        exit 1
    }

    If ($ServiceInstance) {
        $name = $ServiceInstance
        $servicePort = kubectl get services $ServiceInstance -o jsonpath="{.spec.ports[0].port}"
        $targetPort = kubectl get services $ServiceInstance -o jsonpath="{.spec.ports[0].targetPort}" 

    } Else {
        $servicePort = kubectl get services --selector=app=$ServiceName -o jsonpath="{.items..spec.ports[0].port}"
        $targetPort = kubectl get services --selector=app=$ServiceName -o jsonpath="{.items..spec.ports[0].targetPort}" 
    }

    If (!$HostPort) {
        $HostPort = Get-Random -Minimum 8010 -Maximum 9000
    }
    
    Write-Host "Opening http(s)://localhost:$hostPort. Press ctrl-c to cancel..." -ForegroundColor "Green"

    # Launch browser
    If ($Launch) {
        If ( $targetPort -eq "https" ) {
            start "https://localhost:$hostPort"
        } Else {
            start "http://localhost:$hostPort"
        }
    }    

    # Forward port
    Write-Host "kubectl port-forward svc/$name ${hostPort}:${servicePort}"
    kubectl port-forward svc/$name ${hostPort}:${servicePort}

}

# #############################################################################
# Remove a Service
#
Function RemoveService () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Removing Service: $ServiceName                " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    $config = GetProvisionConfig

    If (!$AutoApprove) {
        $confirmation = Read-Host "Are you Sure You Want To Proceed? This cannot be undone. (yes|no):"
        If (!($confirmation -eq 'yes')) {
            Write-Host "Destroy Cancelled" -ForegroundColor "Red"
            Exit 1
        }
    }

    # Remove service
    helm delete $ServiceName --purge

    # Remove hostname
    If ($config.environments.$Environment.hostfile) {
        $hostname = $config.environments.$Environment.hostname
        If ($hostname) {
            Write-Host "Removing $serviceName.$hostname from $HostsFile" -ForegroundColor "Yellow"
            RemoveHost "$serviceName.$hostname"
        } Else {
            Write-Host "You must define an enviroment hostname to add" -ForegroundColor "Red"
            exit 1
        }
    }
}


# #############################################################################
# Setup 
#
Function Setup () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Setting Up Environment                        " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""
    
    # Install chocolatey
    If (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey" -ForegroundColor "Yellow"
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    # Install psyaml parser
    Write-Host "Installing PSYaml Module" -ForegroundColor "Yellow"
    Install-Module PSYaml

    # Install terraform
    If (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Terraform" -ForegroundColor "Yellow"
        choco install -y terraform 
        choco upgrade -y terraform 
    }

    # Environment
    $config = GetProvisionConfig

    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    } Else {
        Write-Host $config.environments.$Environment.description -ForegroundColor "Green"
    } 

    switch ( $config.environments.$Environment.Provider )
    {
        "aws"   { SetupAWS }
        "azure" { SetupAzure }     
        "local" { SetupLocal }   

        default { 
            Write-Host "Unknown Cloud Provider '$CloudProvider'" -ForegroundColor "Red"
            Write-Host "Valid values are AWS and Azure" -ForegroundColor "Red"
            Exit 1
        }
    }    
}


# #############################################################################
# Setup Azure
#
Function SetupAzure () {

    If (!(Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Azure CLI" -ForegroundColor "Yellow"
        choco install azure-cli
    }

}


# #############################################################################
# Setup AWS
#
Function SetupAWS () {

    If (!(Test-Path -Path "~\.aws")){
        New-Item -ItemType directory -Path "~\.aws" > $null
    }

    If (!(Test-Path -Path "~\.aws\heptio")){
        New-Item -ItemType directory -Path "~\.aws\heptio" > $null
    }

    If (!(Test-Path -Path "~\.aws\heptio\heptio-authenticator-aws.exe")) {

        Write-Host "Installing AWS Heptio Authenticator" -ForegroundColor "Yellow"

        Invoke-WebRequest `
            -Uri "https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/windows/amd64/heptio-authenticator-aws.exe" `
            -OutFile "~\.aws\heptio\heptio-authenticator-aws.exe"   
    
        $heptioPath = Resolve-Path -Path "~\.aws\heptio"        
        Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Yellow"
        Write-Host "Added AWS Heptio Authenticator" -ForegroundColor "Yellow"
        Write-Host "Please add '${heptioPath}' to your user PATH" -ForegroundColor "Yellow"
    }
}


# #############################################################################
# Setup Local Cluster
#
Function SetupLocal () {

    # Provision helm
    Write-Host "Provisioning Helm" -ForegroundColor "Yellow"
    helm init

}


# #############################################################################
# SSH into first pod in service
#
Function ShellService () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Connecting to First Pod in Service            " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    Write-Host "Not Yet Implemented" -ForegroundColor "Red"
    exit 1

}


# #############################################################################
# HELPER FUNCTIONS
# #############################################################################


# #############################################################################
# Welcome Message
#
Function Welcome () {

    Write-Host ""
    Write-Host "                    __              " -ForegroundColor "Blue"
    Write-Host "   _________ _____ / /_____  ____   " -ForegroundColor "Blue"
    Write-Host "  / ___/ __ ``/_  // __/ __ \/ __ \ " -ForegroundColor "Blue"
    Write-Host " / /__/ /_/ / / // /_/ /_/ / / / /  " -ForegroundColor "Blue"
    Write-Host " \___/\__,_/ /___\__/\____/_/ /_/   " -ForegroundColor "Blue"        
    Write-Host ""                    

}


# #############################################################################
# Finished
#
Function Finished () {

    $elapsedTime = $(get-date) - $StartTime
    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
    Write-Host "+ Finished in $totalTime"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
    Write-Host ""

}


# #############################################################################
# Parses and returns the provision.yaml configuration
#
Function GetProvisionConfig () {

    If (!(Test-Path -Path "$WorkingDir/provision/provision.yaml")) {
        Write-Host "Cannot find $WorkingDir/provision/provision.yaml" -ForegroundColor "Red"
        Exit 1
    }

    # Write-Host "Importing PSYaml... please wait" -ForegroundColor "Yellow"
    # Import-Module PSYaml

    # Parse provision.yaml into memory with proper line endings
    [string[]]$fileContent = Get-Content "$WorkingDir/provision/provision.yaml"
    $content = ''
    ForEach ($line in $fileContent) { $content = $content + "`n" + $line }

    return ConvertFrom-YAML $content
}


# #############################################################################
# Ensure the kubectl context is set for provision.yaml environment
#
Function EnsureContext () {

    $config = GetProvisionConfig

    # Check provision.yaml
    If (!(Test-Path -Path "$WorkingDir/provision/provision.yaml")) {
        Write-Host "Cannot find $WorkingDir/provision/provision.yaml" -ForegroundColor "Red"
        Exit 1
    }

    # Environment
    If (!($config.environments.$Environment)){
        Write-Host "Environment '$Environment' not found in provision.yaml" -ForegroundColor "Red"
        Exit 1        
    }

    $context = $config.environments.$Environment.context
    If (!$context) {
        Write-Host "Context not set for environment '$Environment' in provision.yaml" -ForegroundColor "Red"
        Exit 1  
    }

    $currentContext = kubectl config current-context 

    If ( $currentContext -ne $context ) {
        Write-Host "Switching kubctl context to: $context" -ForegroundColor "Yellow"
        kubectl config set-context $context
    } Else{
        Write-Host "Using context: $currentContext" -ForegroundColor "Yellow"
    }
}

# #############################################################################
# Adds a host name 
#
Function AddHost([string]$hostname) {

    RemoveHost $hostname
    Start-Sleep -Seconds 3

    $Stoploop = $false
    [int]$Retrycount = "0"
    
    do {
        try {
            $HostsIP + "`t`t" + $hostname | Out-File -Encoding ASCII -Append $HostsFile -Force >> $result # mute error
            Write-Host "Host added" -ForegroundColor "Green"
            $Stoploop = $true
        }
        catch {
            if ($Retrycount -gt 5){
                Write-Host "Could not write host after 5 retrys. Please try again or manually add host" -ForegroundColor "Red"
                $Stoploop = $true
            }
            else {
                Write-Host "Could not write host. Retrying in 3 seconds..." -ForegroundColor "Yellow"
                Start-Sleep -Seconds 3
                $Retrycount = $Retrycount + 1
            }
        }
    }
    While ($Stoploop -eq $false)
    
}


# #############################################################################
# Removes all host names matching $HostsDomain variable (*.domain.com)
#
Function RemoveHost([string]$hostname) {
    $c = Get-Content $HostsFile
    $newLines = @()

    foreach ($line in $c) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -Eq 2) {
            if ($bits[1] -Ne $hostname) {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }

    # Write file
    Clear-Content $HostsFile
    foreach ($line in $newLines) {
        $line | Out-File -Encoding ASCII -Append $HostsFile
    }
}


# #############################################################################
# EXECUTE
# #############################################################################

# Welcome

If ($Dashboard) {
    EnsureContext
    Dashboard
}
ElseIf ($DeployCluster) {
    DeployCluster
}
ElseIf ($DestroyCluster) {
    DestroyCluster
}
ElseIf ($InitContext) {
    InitContext
}
ElseIf ($ProvisionService) {
    EnsureContext
    ProvisionService
}
ElseIf ($ProvisionServiceGroup) {
    EnsureContext
    ProvisionServiceGroup
}
ElseIf ($ProxyService) {
    EnsureContext
    ProxyService
}
ElseIf ($ShellService) {
    EnsureContext
    ShellService
}
ElseIf ($RemoveService) {
    EnsureContext
    RemoveService
}
ElseIf ($Setup) {
    Setup
}

Finished

# #############################################################################
