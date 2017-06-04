# =============================================
# =============================================
# Script name: WinServicesExtensions.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: New-ServiceIfNotExists
# ---------------------------------------------
function New-ServiceIfNotExists
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serviceName,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serviceExecutable,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serviceDisplayName,
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $credential = [System.Management.Automation.PSCredential]::Empty
    )

    # Local variables declaration
    $serviceCreated = $false

    if(!(Get-Service -Name "$serviceName" -ErrorAction SilentlyContinue))
    {
        $moreCmdParameters = @{}

        # Processing additional cmdletr parameters...
        if($credential -ne [System.Management.Automation.PSCredential]::Empty)
        {
            $moreCmdParameters.Add("Credential", $credential)
        }

        # Registering new service with default credentils (Local System Account) or specified account (@moreCmdParameters)
        $serviceStartupType = "Automatic"
        $service = New-Service -Name "$serviceName" `
                               -BinaryPathName "$serviceExecutable" `
                               -DisplayName "$serviceDisplayName" `
                               -StartupType "$serviceStartupType" `
                               @moreCmdParameters

        if($service)
        {
            # Setting advanced service options (this is possible only by using sc.exe)
            # There is not powershelis way how to achieve this using only powershell
            sc.exe failure $serviceName reset= 86400 actions= restart/30000/restart/30000/restart/30000

            $serviceCreated = $true
        }
    }

    return ($result)
}

# ---------------------------------------------
# Function: Remove-ServiceIfExists
# ---------------------------------------------
function Remove-ServiceIfExists
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serviceName
    )

    # Deleting service if exists
    $service = Get-Service -Name "$serviceName" -ErrorAction SilentlyContinue
    if($service)
    {
        # Stopping service if running
        if($service.Status -eq "Running")
        {
            sc.exe stop $serviceName
        }

        # Deleting service
        sc.exe delete $serviceName

        # Wait one second until operating system delete the service
        Start-Sleep -Seconds 1
    }
}