# Get information from rdm.conf and command
$currentUserName = [System.Environment]::UserName
if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
    $osType = "Windows"
} elseif ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) {
    $osType = "Linux"
} elseif ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) {
    $osType = "macOS"
} else {
    $osType = "Unknown"
}
# Set rdmsshConfig path based on the operating system
if ($osType -eq "Windows") {
    $rdmsshConfig = "C:\Users\$currentUserName\rdmcli\rdm.conf"
    $rdmsshConfigFolder = "C:\Users\$currentUserName\rdmcli"
} else {
    $rdmsshConfig = "/Users/$currentUserName/rdmcli/rdm.conf"
    $rdmsshConfigFolder = "/Users/$currentUserName/rdmcli"
}
$dataSource = ""
$vaultName = ""

# Check if the configuration file exists
if (Test-Path $rdmsshConfig) {
    # Read the configuration file line by line
    $configLines = Get-Content $rdmsshConfig

    # Loop through each line
    foreach ($line in $configLines) {
        # Check for the dataSource line
        if ($line -like "datasource =*") {
            $dataSource = $line.Split("=")[1].Trim()
        }
        # Check for the vault line
        elseif ($line -like "vault =*") {
            $vaultName = $line.Split("=")[1].Trim()
        }
    }
} else {
    Write-Host "Configuration file not found: $rdmsshConfig run 'rdmotp config' to create it"
    exit
}
# Import Module
Import-Module Devolutions.PowerShell | Out-Null
# Set data source
Get-RDMDataSource -Name $dataSource -ForcePromptAnswer yes | Set-RDMcurrentDataSource -ForcePromptAnswer yes
# Set vault
$vaultID = Get-RDMVault -Name $vaultName -ForcePromptAnswer yes | Select-Object ID
Set-RDMCurrentVault -ID $vaultID.ID | Out-Null

# Find sessions
$sharedSessions = Get-RDMSession
$privateSessions = Get-RDMPrivateSession
# Define initial searches
$search1 = $sharedSessions | Where-Object { $_.Name -like "*_otp" } | Select-Object Name,Id
$search2 = $privateSessions | Where-Object { $_.Name -like "*_otp" } | Select-Object Name,Id

# List all otp sessions
Write-Host -ForegroundColor Green "_______________________________________"
Write-Host -ForegroundColor Blue "Listing all otp sessions"
Write-Host -ForegroundColor Green "_______________________________________"
    $sessionNumber = 1
    $resultNumber = 1
    $result = @()

    if ($search1.Count -gt 0) {
        foreach ($session in $search1) {
            $output = "$sessionNumber. - $($session.Name)`t$($session.Id)"
            Write-Host -ForegroundColor Green $output
            $resultVariable = "result$resultNumber"
            New-Variable -Name $resultVariable -Value $output -Force
            $result += $resultVariable
            $sessionNumber++
            $resultNumber++
        }
    }

    if ($search2.Count -gt 0) {
        foreach ($session in $search2) {
            $output = "$sessionNumber. - $($session.Name)`t$($session.Id)"
            Write-Host -ForegroundColor Green $output
            $resultVariable = "result$resultNumber"
            New-Variable -Name $resultVariable -Value $output -Force
            $result += $resultVariable
            $sessionNumber++
            $resultNumber++
        }
    }
    Write-Host $results