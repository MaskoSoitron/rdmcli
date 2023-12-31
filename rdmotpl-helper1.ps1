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
$datasourceID = Get-RDMDataSource -Name $dataSource -ForcePromptAnswer yes 
$setDataSource = Set-RDMcurrentDataSource -ForcePromptAnswer yes -ID $datasourceID.ID
start-sleep -s 1
$currentDataSource = Get-RDMcurrentDataSource


# Find sessions
$sharedSessions = Get-RDMSession
$search1 = $sharedSessions | Where-Object { $_.Name -like "*_otp" -or $_.Group -eq "OTP" } | Select-Object Name,Id

# List all otp sessions

$sessionNumber = 1

foreach ($session in $search1) {
    $output = "$sessionNumber. - $($session.Name)`t$($session.Id)"
    #Write-Host -ForegroundColor Green $output  # Output each session

    $results += "$output`n"  # Append each session to results

    $sessionNumber++
}

# Define a secure temporary file
$tempFile = [System.IO.Path]::GetTempFileName()

# Write the result to the temporary file
[System.IO.File]::WriteAllText($tempFile, $results)

# Output the temporary file path so that the Bash script knows where to look
Write-Output $tempFile