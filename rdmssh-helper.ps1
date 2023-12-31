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
    Write-Host "Configuration file not found: $rdmsshConfig run 'rdmssh config' to create it"
    exit
}
$FindUsername = $args[0]
$FindHostname = $args[1]
# Import Module
Import-Module Devolutions.PowerShell | Out-Null
# Set data source
Get-RDMDataSource -Name $dataSource -ForcePromptAnswer yes | Set-RDMcurrentDataSource -ForcePromptAnswer yes
# Set vault
$vaultID = Get-RDMVault -Name $vaultName | Select-Object ID
Set-RDMCurrentVault -ID $vaultID.ID | Out-Null

# Find sessions
# Define initial searches
$search1 = Get-RDMSession | Where-Object { $_.Host -eq "$FindHostname" -and $_.HostUserName -eq "$FindUsername" } | Select-Object Host, HostUserName, Id
$search2 = Get-RDMSession | Where-Object { $_.Host -eq "$FindHostname" -and $_.HostUserName -eq $null } | Select-Object Host, HostUserName, Id
$search3 = Get-RDMPrivateSession | Where-Object { $_.Host -eq "$FindHostname" -and $_.HostUserName -eq "$FindUsername" } | Select-Object Host, HostUserName, Id
$search4 = Get-RDMPrivateSession | Where-Object { $_.Host -eq "$FindHostname" -and $_.HostUserName -eq $null } | Select-Object Host, HostUserName, Id

# Search 1
if ($search1.Count -eq 1) {
    $searchID = $search1.Id
} elseif ($search1.Count -gt 1) {
    $searchID = $search1[0].Id
} else {
    $searchID = $null
}

# Search 2 - Run only if $searchID is null
if ($searchID -eq $null) {
    if ($search2.Count -eq 1) {
        $searchID2 = $search2.Id
        $username = Get-RDMSessionUserName -ID $searchID2
        if ($FindUsername -eq $username) {
            $searchID = $searchID2
        }
    } elseif ($search2.Count -gt 1) {
        $searchID2 = $search2[0].Id
        $username = Get-RDMSessionUserName -ID $searchID2
        if ($FindUsername -eq $username) {
            $searchID = $searchID2
        }
    }
}

# Search 3 - Run only if $searchID is null
if ($searchID -eq $null) {
    if ($search3.Count -eq 1) {
        $searchID = $search3.Id
    } elseif ($search3.Count -gt 1) {
        $searchID = $search3[0].Id
    }
}

# Search 4 - Run only if $searchID is null
if ($searchID -eq $null) {
    if ($search4.Count -eq 1) {
        $searchID4 = $search4.Id
        $username = Get-RDMSessionUserName -ID $searchID4
        if ($FindUsername -eq $username) {
            $searchID = $searchID4
        }
    } elseif ($search4.Count -gt 1) {
        $searchID4 = $search4[0].Id
        $username = Get-RDMSessionUserName -ID $searchID4
        if ($FindUsername -eq $username) {
            $searchID = $searchID4
        }
    }
}


# If not found at all, perform this
If ($searchID -eq $null){
	$result = "No session found in RDM with address $FindHostname and user $FindUsername"
	exit
}

If ($searchID -ne $null) {
    $result1 = $null
    $result2 = $null

    # Try to get password from private session
    Try {
        $result1 = Get-RDMPrivateSessionPassword -ID $searchID | ConvertFrom-SecureString -AsPlainText
    } Catch {
        $result1 = $null
    }

    # Try to get password from shared session
    Try {
        $result2 = Get-RDMSessionPassword -ID $searchID | ConvertFrom-SecureString -AsPlainText
    } Catch {
        $result2 = $null
    }

    # Decide which result to use
    if ($result1 -ne $null) {
        $result = $result1
    } elseif ($result2 -ne $null) {
        $result = $result2
    } else {
        $result = "No session found in RDM with address $FindHostname and user $FindUsername"
    }
} else {
    $result = "No session found in RDM with address $FindHostname and user $FindUsername"
}

# Define a secure temporary file
$tempFile = [System.IO.Path]::GetTempFileName()

# Write the result to the temporary file
[System.IO.File]::WriteAllText($tempFile, $result)

# Output the temporary file path so that the Bash script knows where to look
Write-Output $tempFile