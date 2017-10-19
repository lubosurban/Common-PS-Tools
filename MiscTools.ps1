# =============================================
# =============================================
# Script name: MiscTools.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: Clear-DirectorySubTree
# ---------------------------------------------
function Clear-DirectorySubTree
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $directory,
        [String[]] $excludedDirectories,
        [String[]] $excludedFiles
    )

    $allItemsRemoved = $true

    foreach($item in Get-ChildItem -Path $directory -Force)
    {

        if($item.Attributes -match "Directory")
        {
            $preserveDir = $false

            $i = 0
            while((!$preserveDir) -and ($i -lt $excludedDirectories.Length))
            {
                $preserveDir = $item.FullName -like $excludedDirectories[$i]
                $i++
            }

            if($preserveDir)
            {
                $allItemsRemoved = $false
            }
            elseif (!(Clear-DirectorySubTree -directory $item.FullName -excludedDirectories $excludedDirectories -excludedFiles $excludedFiles))
            {
                $allItemsRemoved = $false
            }
        }
        else
        {
            $preserveFile = $false

            $i = 0
            while((!$preserveFile) -and ($i -lt $excludedFiles.Length))
            {
                $preserveFile = $item.FullName -like $excludedFiles[$i]
                $i++
            }

            if($preserveFile)
            {
                $allItemsRemoved = $false
            }
            else
            {
                Remove-Item -Path $item.FullName -Force | Out-Null
            }
        }
    }

    if($allItemsRemoved)
    {
        Remove-Item -Path "$directory" -Recurse -Force | Out-Null
    }

    return($allItemsRemoved)
}

# ---------------------------------------------
# Function: Start-ProcessAndValidateExitCode
# ---------------------------------------------
function Start-ProcessAndValidateExitCode
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $executable,
    [String]
    $parameters
  )

  try
  {
    if($parameters)
    {
      $process = Start-Process -Wait -FilePath $executable -ArgumentList $parameters -PassThru
    }
    else
    {
      $process = Start-Process -Wait -FilePath $executable -PassThru
    }
  }
  catch
  {
    throw("Unable to execute `"$executable $parameters`", executable file probably does not exists or it is not valid executable file.")
  }

  if($process.ExitCode -ne 0)
  {
    throw("Process (`"$executable $parameters`") execution terminated with exit code: " + $process.ExitCode)
  }
}
