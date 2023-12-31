#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Step 1: Check if PowerShell is installed
if ! command_exists pwsh; then
  read -p "PowerShell is not installed. Do you want to install it? (y/n): " -r
  echo    # Move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing PowerShell..."
    # Add your installation command here (e.g., for Homebrew)
    # Example: brew install --cask powershell
    # Replace this line with the appropriate installation command for your system
    exit
  else
    echo "Installation canceled. PowerShell is required to continue."
    exit 1
  fi
else
  echo "PowerShell is installed."
fi

# Step 2: Check if sshpass is installed
if ! command_exists sshpass; then
  read -p "sshpass is not installed. Do you want to install it? (y/n): " -r
  echo    # Move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing sshpass..."
    # Add your installation command here (e.g., for Homebrew)
    # Example: brew install sshpass
    # Replace this line with the appropriate installation command for your system
    exit
  else
    echo "Installation canceled. sshpass is required to continue."
    exit 1
  fi
else
  echo "sshpass is installed."
fi

# Step 3: Check if Devolutions.PowerShell module is installed
if ! pwsh -Command "Get-Module -ListAvailable Devolutions.PowerShell" | grep -q "Devolutions.PowerShell"; then
  read -p "Devolutions.PowerShell module is not installed. Do you want to install it? (y/n): " -r
  echo    # Move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Devolutions.PowerShell module..."
    # Add your installation command for the module here
    # Example: pwsh -Command "Install-Module -Name Devolutions.PowerShell -Scope CurrentUser"
    # Replace this line with the appropriate installation command
  else
    echo "Installation canceled. Devolutions.PowerShell module is required to continue."
    exit 1
  fi
else
  echo "Devolutions.PowerShell module is installed."
fi

# Step 4: Create the target directory
currentUserName=$(whoami)
targetDir="/Users/$currentUserName/RDMExtras"
if [ ! -d "$targetDir" ]; then
  mkdir -p "$targetDir"
  echo "Created directory: $targetDir"
else
  echo "Directory $targetDir already exists."
fi

# Step 5: Copy all files (except install.sh) to the target directory
shopt -s extglob
for file in !(install.sh); do
  cp "$file" "$targetDir"
  echo "$file copied to $targetDir"
done

# Step 6: Add PATH to .bash_profile if not already present
bash_profile="/Users/$currentUserName/.bash_profile"
path_entry='export PATH="~/RDMExtras:$PATH"'

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