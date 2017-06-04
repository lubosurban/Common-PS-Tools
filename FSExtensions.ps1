# =============================================
# =============================================
# Script name: FSExtensions.ps1
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
            elseif (!(Remove-ApplicationFiles -directory $item.FullName -excludedDirectories $excludedDirectories -excludedFiles $excludedFiles))
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
