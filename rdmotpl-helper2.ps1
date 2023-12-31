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

# Check if the configuration file exists
if (Test-Path $rdmsshConfig) {
    # Read the configuration file line by line
    $configLines = Get-Content $rdmsshConfig

    # Loop through each line
    foreach ($line in $configLines) {
        # Check for the dataSource line
        if ($line -like "personaldatasource =*") {
            $dataSource = $line.Split("=")[1].Trim()
        }
    }
} else {
    Write-Host "Configuration file not found: $rdmsshConfig run 'rdmotp config' to create it"
    exit
}
# Import Module
Import-Module Devolutions.PowerShell | Out-Null
# Set data source
$dsid = Get-RDMDataSource -ForcePromptAnswer yes | where {$_.Name -eq "$dataSource"} | select ID
Set-RDMCurrentDataSource -ID $dsid.id -ForcePromptAnswer yes

$otpID = $args[0]

# Get OTP from session
$otp = Get-RDMSessionPassword -ID "$otpID" -AsPlainText
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
