# =============================================
# =============================================
# Script name: SQLServerExtensions.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: Import-SqlServerModule
# ---------------------------------------------
function Import-SqlServerModule
{
    # Checks if the SqlServer module is available
    if (Get-Module -ListAvailable -Name SqlServer)
    {
        # Module found, proceed with import
        Import-Module SqlServer -ErrorAction Stop
    }
    else
    {
        # Module not found, the script cannot continue
        Write-Error "Modul `"SqlServer`" nie je nainštalovaný. Nainštalujte ho pomocou: Install-Module SqlServer"
        throw "Modul `"SqlServer`" nie je nainštalovaný"
    }
}

# ---------------------------------------------
# Function: Invoke-SqlQuery
# ---------------------------------------------
function Invoke-SqlQuery
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $query,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $database,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("QueryTimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }

    return Invoke-Sqlcmd -Query $query -ServerInstance $serverInstance -Database $database -ErrorAction Stop @moreCmdParameters
}

# ---------------------------------------------
# Function: Invoke-SqlFile
# ---------------------------------------------
function Invoke-SqlFile
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $inputFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $database,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("QueryTimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }


    Invoke-Sqlcmd -InputFile $inputFile -ServerInstance $serverInstance -Database $database -ErrorAction Stop @moreCmdParameters
}

# ---------------------------------------------
# Function: Invoke-SqlFileAtServerLevel
# ---------------------------------------------
function Invoke-SqlFileAtServerLevel
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $inputFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("QueryTimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }


    Invoke-Sqlcmd -InputFile $inputFile -ServerInstance $serverInstance -ErrorAction Stop @moreCmdParameters
}
