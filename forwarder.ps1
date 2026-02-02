<#
==============================================================================
.SYNOPSIS
    Remote port forwarding script via AWS SSM Session Manager

.DESCRIPTION
    Advanced PowerShell version with auto-reconnect, SSO authentication,
    auto port assignment, and bastion host state checking for connection

.AUTHOR
    Petro Sydor

.VERSION
    1.5.0 (2026-01-21)

.LICENSE
    MIT License / Community Contribution Rules

.PARAMETER RemoteHost
    Remote host/database AWS DNS name (default: dev-webapp-nhs-db.ckn9btrppujn.eu-west-2.rds.amazonaws.com)

.PARAMETER RemotePort
    Remote port for connection (default: 5432)

.PARAMETER LocalPort
    Local port for exposing (default: 15432)

.PARAMETER AwsProfile
    AWS SSO profile name (default: akrivia-development)

.PARAMETER BastionHost
    Jump/bastion host instance ID (default: i-0a9ce8d5281f39d6b)

.PARAMETER Region
    AWS region (default: eu-west-2)

.PARAMETER AutoPort
    Auto assign free local port for exposing (overrides LocalPort)

.EXAMPLE
    .\forwarder.ps1 -RemoteHost "dev.rds.amazon.com" -AwsProfile "my-profile" -BastionHost "i-123" -LocalPort 5432 -RemotePort 5432 -Region "eu-west-2"

.EXAMPLE
    .\forwarder.ps1 -AutoPort

.NOTES
    Press Ctrl+C to stop auto reconnect
==============================================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RemoteHost = $env:REMOTE_HOST,
    
    [Parameter(Mandatory=$false)]
    [int]$RemotePort = $(if ($env:REMOTE_PORT) { [int]$env:REMOTE_PORT } else { 5432 }),
    
    [Parameter(Mandatory=$false)]
    [int]$LocalPort = $(if ($env:LOCAL_PORT) { [int]$env:LOCAL_PORT } else { 15432 }),
    
    [Parameter(Mandatory=$false)]
    [string]$AwsProfile = $env:AWS_PROFILE,
    
    [Parameter(Mandatory=$false)]
    [string]$BastionHost = $env:JUMP_HOST,
    
    [Parameter(Mandatory=$false)]
    [string]$Region = $env:REGION,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoPort
)

# Set default values if environment variables are not set
if (-not $RemoteHost) { $RemoteHost = 'dev-webapp-nhs-db.ckn9btrppujn.eu-west-2.rds.amazonaws.com' }
if (-not $AwsProfile) { $AwsProfile = 'akrivia-development' }
if (-not $BastionHost) { $BastionHost = 'i-0a9ce8d5281f39d6b' }
if (-not $Region) { $Region = 'eu-west-2' }

# Script configuration
$VERSION = '1.5'
$BASTION_CHECK_SLEEP_INTERVAL = 15

# Set error action preference
$ErrorActionPreference = "Stop"

# Display script information
Write-Host @"
Remote port forwarding script v.$VERSION via AWS SSM Session Manager

 - allow to reconfigure parameters via args. You could use with other wrappers or command line execution
 - check of the jump/bastion host is in the running state
 - auto reconnect when SSO session will be expired or connection lost
 - auto port assignment for local exposed port

PARAMETERS:

    -RemoteHost       Redefine remote host for connection (environment variable REMOTE_HOST, default: '$RemoteHost')
    -RemotePort       Redefine remote port for connection (environment variable REMOTE_PORT, default: $RemotePort)
    -LocalPort        Redefine local port for exposing (environment variable LOCAL_PORT, default: $LocalPort)
    -AwsProfile       Redefine AWS SSO profile (environment variable AWS_PROFILE, default: '$AwsProfile')
    -BastionHost      Redefine jump/bastion host instance id (environment variable JUMP_HOST, default: '$BastionHost')
    -Region           Redefine AWS region (environment variable REGION, default: '$Region')
    -AutoPort         Auto assign free local port for exposing. Will override LOCAL PORT (No value required)

USAGE:
  
    .\forwarder.ps1 -RemoteHost REMOTE-HOST-DNS-NAME -AwsProfile SSM-PROFILE -RemotePort REMOTE-PORT -LocalPort LOCAL-PORT -BastionHost BASTION-INSTANCE-ID -Region REGION -AutoPort
    or
    .\forwarder.ps1 -RemoteHost "dev.rds.amazon.com" -AwsProfile "my-profile" -BastionHost "i-123" -LocalPort 5432 -RemotePort 5432 -Region "eu-west-2"

INFO: 
    Ctrl+C to stop auto reconnect

"@

# Function to find a free local port
function Find-FreePort {
    while ($true) {
        $port = Get-Random -Minimum 49152 -Maximum 65535
        $tcpConnection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if (-not $tcpConnection) {
            return $port
        }
    }
}

# Process AutoPort switch
if ($AutoPort) {
    $LocalPort = Find-FreePort
    Write-Host "[Info] Auto assign local exposed port to '$LocalPort'"
}

# Display configuration
Write-Host "[Info] Remote host: '$RemoteHost'"
Write-Host "[Info] Remote port: '$RemotePort'"
Write-Host "[Info] Local port: '$LocalPort'"
Write-Host "[Info] AWS SSO profile: '$AwsProfile'"
Write-Host "[Info] Jump/bastion host: '$BastionHost'"
Write-Host "[Info] AWS region: '$Region'"

# Check AWS CLI installation
Write-Host "[Info] Checking AWS CLI v2 installation: " -NoNewline
try {
    $awsVersion = aws --version 2>&1
    Write-Host $awsVersion
} catch {
    Write-Host "`n[Error] AWS CLI v2 is not installed or not available in PATH. Please install AWS CLI v2 to use this script."
    exit 1
}

# Check Session Manager Plugin installation
Write-Host "[Info] Checking AWS Session Manager Plugin installation: " -NoNewline
try {
    if (Test-Path "C:\Program Files\Amazon\SessionManagerPlugin\bin\session-manager-plugin.exe") {
        $pluginVersion = & "C:\Program Files\Amazon\SessionManagerPlugin\bin\session-manager-plugin.exe" --version 2>&1
        Write-Host $pluginVersion
    } elseif (Get-Command session-manager-plugin -ErrorAction SilentlyContinue) {
        $pluginVersion = session-manager-plugin --version 2>&1
        Write-Host $pluginVersion
    } else {
        Write-Host "`n[Error] AWS Session Manager Plugin is not installed or not available in PATH. Please install Session Manager Plugin to use this script."
        exit 1
    }
} catch {
    Write-Host "`n[Warning] Could not verify Session Manager Plugin installation."
}

Write-Host "[Info] Connecting to the '$RemoteHost`:$RemotePort' in the '$Region' AWS region"
Write-Host "[Info] Port forward with profile '$AwsProfile' to the port '$LocalPort'"

# Function for Ctrl+C handler
function Exit-Gracefully {
    Write-Host "`n[Info] Stopping execution, 'Ctrl + C' caught. Exiting..."
    exit 0
}

# Register Ctrl+C handler
[Console]::TreatControlCAsInput = $false
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "[Info] Termination signal caught. Exiting..."
}

# Function for SSM connection
function Start-SsmConnection {
    param(
        [string]$Profile,
        [string]$RemoteHost,
        [string]$Bastion,
        [int]$RemotePort,
        [int]$LocalPort,
        [string]$Region
    )
    
    Write-Host "[INFO] Starting SSM session"
    try {
        aws ssm start-session `
            --region $Region `
            --target $Bastion `
            --document-name AWS-StartPortForwardingSessionToRemoteHost `
            --parameters "host=$RemoteHost,portNumber=$RemotePort,localPortNumber=$LocalPort" `
            --profile $Profile
    } catch {
        Write-Host "[Error] Session terminated or unable to connect."
    }
    Write-Host "[Info] Port forwarding session has been closed/terminated or not able to connect."
}

# Main execution loop
try {
    Write-Host "[Info] Getting SSO token ..."
    try {
        aws sso login --profile $AwsProfile
    } catch {
        Write-Host "[Error] Not able to login via SSO"
    }

    Write-Host "[Info] Waiting for running state of the jump/bastion host '$BastionHost' " -NoNewline
    
    # Check bastion host state
    $instanceState = aws ec2 describe-instances `
        --instance-ids $BastionHost `
        --output text `
        --query 'Reservations[*].Instances[*].State.Name' `
        --region $Region `
        --profile $AwsProfile

    while ($instanceState -ne "running") {
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds $BASTION_CHECK_SLEEP_INTERVAL
        
        $instanceState = aws ec2 describe-instances `
            --instance-ids $BastionHost `
            --output text `
            --query 'Reservations[*].Instances[*].State.Name' `
            --region $Region `
            --profile $AwsProfile
    }
    
    Write-Host ""
    Write-Host "[Info] Jump/bastion host '$BastionHost' is in the running state"
    Write-Host "[Info] Starting port forwarding connection"

    # Connection loop with auto-reconnect
    while ($true) {
        try {
            Start-SsmConnection -Profile $AwsProfile `
                -RemoteHost $RemoteHost `
                -Bastion $BastionHost `
                -RemotePort $RemotePort `
                -LocalPort $LocalPort `
                -Region $Region
        } catch {
            Write-Host "[Error] Can't provide port forwarding with a SSH tunnel via AWS SSM"
        }
        
        Write-Host "[INFO] Getting SSO token ..."
        try {
            aws sso login --profile $AwsProfile
        } catch {
            Write-Host "[Warning] SSO login failed, retrying..."
        }
    }
} catch {
    Write-Host "[Error] An unexpected error occurred: $_"
    exit 1
} finally {
    # Cleanup code if needed
    Write-Host "[Info] Script execution completed."
}
