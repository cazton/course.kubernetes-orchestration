
<#
.SYNOPSIS
	Orchestrates the platform services
.PARAMETER Setup
	Loads all provisioning dependencies
.PARAMETER Environment
	The environment to build for (Debug or Release), defaults to Debug
.EXAMPLE
	C:\PS> .\project-tasks.ps1 -Setup
#>


# #############################################################################
# Params (switch params is last method in script)
#
[CmdletBinding(PositionalBinding = $false)]
Param(
    [Switch]$Setup,
    [Switch]$AssignCredentials,
    [ValidateNotNullOrEmpty()]
    [String]$Environment = "Debug"
)


# #############################################################################
# Parent directory (for sibling project folders)
#
$Environment = $Environment.ToLowerInvariant()
$ProjectDir = (Get-Item -Path "..\" -Verbose).FullName
$WorkingDir = (Get-Item -Path ".\" -Verbose).FullName


# #############################################################################
# Welcome message.
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
# Setup 
#
Function AssignCredentials () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Setting up kubectl credentials                " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""

    # $server = (terraform output host) | Out-String
    # $clusterCert = (terraform output cluster_ca_certificate) | Out-String | Set-Content "./.azure/cluster_ca"

    # kubectl config set-cluster k8stest --server=$server --certificate-authority="./.azure/cluster_ca" --embed-certs=true

    # $clientCert = (terraform output client_certificate) | Out-String | Set-Content "./.azure/client_rsa"
    # $clientKey = (terraform output client_key) | Out-String | Set-Content "./.azure/client_key"
    # kubectl config set-credentials k8stest-admin --client-key="./.azure/client_key" --embed-certs=true

    # kubectl config set-context azure --cluster=k8stest --user=k8stest-admin

    az aks get-credentials --resource-group azure-k8stest --name k8stest
}

# #############################################################################
# Setup 
#
Function Setup () {

    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Setting up services                           " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host ""
    
    

}


# #############################################################################
# Switch parameters
#

Welcome

If ($Setup) {
    Setup
} 
ElseIf ($AssignCredentials) {
    AssignCredentials
}


# #############################################################################
