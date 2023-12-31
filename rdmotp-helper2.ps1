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
    $rdmsshConfig = "C:\Users\$currentUserName\RDMExtras\rdm.conf"
    $rdmsshConfigFolder = "C:\Users\$currentUserName\RDMExtras"
} else {
    $rdmsshConfig = "/Users/$currentUserName/RDMExtras/rdm.conf"
    $rdmsshConfigFolder = "/Users/$currentUserName/RDMExtras"
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
$otpID = $args[0]

# Get OTP from session
$otp = Get-RDMSessionPassword -ID $otpID -AsPlainText
if ($null -eq $otp) {
    Get-RDMPrivateSessionPassword -ID $otpID -AsPlainText
}
if ($null -eq $otp) {
    Write-Host -ForegroundColor Red "failure"
    exit
}

# Verify if $otp contains 4-10 numbers
if ($otp -match '^\d{4,10}$') {
    Write-Host -ForegroundColor Green $otp
} else {
    Write-Host -ForegroundColor Red "failure"
}