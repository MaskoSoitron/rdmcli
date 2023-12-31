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
Write-Host "Importing ps module..."
# Set data source
Get-RDMDataSource | where {$_.Name -eq "$dataSource"} | Set-RDMcurrentDataSource
Write-Host "Data source set to $dataSource"
$SelectedSource = Get-RDMCurrentDataSource
Write-Host "Current data source is $SelectedSource"
# Find sessions
$sharedSessions = Get-RDMSession -ForcePromptAnswer yes
Write-Host "Getting sessions..."
write-host "Found $($sharedSessions.count) sessions"
# Define initial searches
$search1 = $sharedSessions | Where-Object { $_.Name -like "*_otp" -or $_.Group -eq "OTP"} | Select-Object Name,Id
write-host "Found $($search1.count) otp sessions"

# Specify the output file path
$outputFilePath = Join-Path -Path $rdmsshConfigFolder -ChildPath "rdmotpl-cache.txt"

# Generate the header
$header = @"
_______________________________________
Listing all otp sessions
_______________________________________
"@

# List all otp sessions
Write-Host -ForegroundColor Green $header  # Display the header
$result = @($header) + $result  # Add the header to the results

$sessionNumber = 1
$resultNumber = 1

foreach ($session in $search1) {
    $output = "$sessionNumber. - $($session.Name)`t$($session.Id)"
    Write-Host -ForegroundColor Green $output
    $resultVariable = "result$resultNumber"
    New-Variable -Name $resultVariable -Value $output -Force
    $result += $resultVariable
    $sessionNumber++
    $resultNumber++
}
