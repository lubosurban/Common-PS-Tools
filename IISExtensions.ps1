$ErrorActionPreference = "Stop"

#* ---------------------------------------------
#* Import-WebAdministrationModule
#* ---------------------------------------------
function Import-WebAdministrationModule
{
    Import-Module WebAdministration
}

#* ---------------------------------------------
#* Function: New-WebAppPoolIfNotExists
#* ---------------------------------------------
function New-WebAppPoolIfNotExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $appPoolName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $managedRuntimeVersion,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Classic", "Integrated")]
        [String] $managedPipelineMode,
        [Parameter(Mandatory=$false)]
        [Boolean] $loadUserProfile = $false,
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        $credential = [System.Management.Automation.PSCredential]::Empty
    )

    $poolCreated = $false

    if(!(Test-Path -Path "IIS:\AppPools\$appPoolName"))
    {
        New-WebAppPool -Name $appPoolName -Force

        # For a complete list of ApplicationPool properties check: http://www.iis.net/ConfigReference/system.applicationHost/applicationPools/applicationPoolDefaults
        # -----------------------------
        # Set "RuntimeVersion"
        # -----------------------------
        Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "managedRuntimeVersion" -Value "$managedRuntimeVersion"

        # -----------------------------
        # Set "PipelineMode"
        # -----------------------------
        $managedPipelineModeInt = 0;
        if($managedPipelineMode -eq "Classic")
        {
          $managedPipelineModeInt = 1;
        }
        Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "managedPipelineMode" -Value $managedPipelineModeInt

        # -----------------------------
        # Set "ProcessModel""
        # -----------------------------
        # For more details about Process model see: http://www.iis.net/configreference/system.applicationhost/applicationpools/add/processmodel
        if($credential -ne [System.Management.Automation.PSCredential]::Empty)
        {
            Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "ProcessModel.identityType" -value 3
            Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "ProcessModel.userName" -value $credential.UserName
            Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "ProcessModel.password" -value $credential.GetNetworkCredential().Password
            Set-ItemProperty -Path "IIS:\AppPools\$appPoolName" -Name "ProcessModel.loadUserProfile" -value $loadUserProfile
        }

        $poolCreated = $true
    }

    return($poolCreated)
}

#* ---------------------------------------------
#* Function: Remove-WebAppPoolIfExists
#* ---------------------------------------------
function Remove-WebAppPoolIfExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $appPoolName
    )

    if(Test-Path -Path "IIS:\AppPools\$appPoolName")
    {
        Remove-WebAppPool -Name "$appPoolName"
    }
}

#* ---------------------------------------------
#* Function: Restart-WebAppPoolEx
#* ---------------------------------------------
function Restart-WebAppPoolEx
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $appPoolName
    )

    $state = (Get-WebAppPoolState -Name "$appPoolName").Value
    if($state -ieq "Stopped")
    {
        Start-WebAppPool -Name "$appPoolName"
    }
    elseif($state -ieq "Started")
    {
        Restart-WebAppPool -Name "$appPoolName"
    }
}

#* ---------------------------------------------
#* Function: New-WebSiteIfNotExists
#* ---------------------------------------------
function New-WebsiteIfNotExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $websiteName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $websitePhysicalPath,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $applicationPool
    )

    $websiteCreated = $false

    if(!(Get-Website -Name "$websiteName"))
    {
        New-Website -Name "$websiteName" -PhysicalPath "$websitePhysicalPath" -ApplicationPool "$applicationPool" -Force

        $websiteCreated = $true
    }

    return($websiteCreated)
}

#* ---------------------------------------------
#* Function: Remove-WebSiteIfExists
#* ---------------------------------------------
function Remove-WebsiteIfExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webSiteName
    )

    if(Get-Website -Name "$webSiteName")
    {
        Remove-Website -Name "$webSiteName"
    }
}

#* ---------------------------------------------
#* Function: New-WebApplicationIfNotExists
#* ---------------------------------------------
function New-WebApplicationIfNotExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webSiteName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webAppName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webAppPhysicalPath,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $applicationPool
    )

    $webApplicationCreated = $false

    if(!(Get-WebApplication -Site "$webSiteName" -Name "$webAppName"))
    {
        New-WebApplication -Site "$webSiteName" -Name "$webAppName" -PhysicalPath "$webAppPhysicalPath" -ApplicationPool "$applicationPool" -Force

        $webApplicationCreated = $true
    }

    return($webApplicationCreated)
}

#* ---------------------------------------------
#* Function: Remove-WebApplicationIfExists
#* ---------------------------------------------
function Remove-WebApplicationIfExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webSiteName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $webAppName
    )

    if(Get-WebApplication -Site "$webSiteName" -Name "$webAppName")
    {
        Remove-WebApplication -Site "$webSiteName" -Name "$webAppName"
    }
}