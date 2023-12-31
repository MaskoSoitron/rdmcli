#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Step 1: Verify pre-requisites

# Check if PowerShell, sshpass, and Devolutions.PowerShell module are installed
requirements_ok=true

# Check if PowerShell is installed
if ! command_exists pwsh; then
  echo "Verifying if PowerShell is installed... Fail"
  requirements_ok=false
else
  echo "Verifying if PowerShell is installed... OK"
fi

# Check if sshpass is installed
if ! command_exists sshpass; then
  echo "Verifying if sshpass is installed... Fail"
  requirements_ok=false
else
  echo "Verifying if sshpass is installed... OK"
fi

# Check if Devolutions.PowerShell module is installed
if ! pwsh -Command "Get-Module -ListAvailable Devolutions.PowerShell" | grep -q "Devolutions.PowerShell"; then
  echo "Verifying if Devolutions.PowerShell module is installed... Fail"
  requirements_ok=false
else
  echo "Verifying if Devolutions.PowerShell module is installed... OK"
fi

# If any requirement check failed, exit with an error message
if [ "$requirements_ok" = false ]; then
  echo "Requirements check failed. Please install missing software manually."
  exit 1
fi

# Step 2: Create the target directory
currentUserName=$(whoami)
targetDir="/Users/$currentUserName/rdmcli"
if [ ! -d "$targetDir" ]; then
  mkdir -p "$targetDir"
  echo "Created directory: $targetDir"
else
  echo "Directory $targetDir already exists."
fi

# Step 3: Copy all files (except install.sh) to the target directory
shopt -s extglob
for file in !(install.sh); do
  cp "$file" "$targetDir"
  echo "$file copied to $targetDir"
done

# Step 4: Add PATH to .bash_profile if not already present
bash_profile="/Users/$currentUserName/.bash_profile"
path_entry='export PATH="~/rdmcli:$PATH"'

if ! grep -q "$path_entry" "$bash_profile"; then
  echo "$path_entry" >> "$bash_profile"
  echo "Added PATH entry to $bash_profile"
else
  echo "PATH entry already exists in $bash_profile"
fi

# Source the .bash_profile to apply changes immediately
source "$bash_profile"

echo "Installation completed. You may need to restart your terminal or run 'source ~/.bash_profile' for changes to take effect."
echo "Run 'rdmssh help' or 'rdmotp help' for more information."