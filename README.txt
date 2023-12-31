------------------------------------
Requirements: sshpass, powershell, Devolutions.Powershell module
------------------------------------

This tool allows you to use command "rdmssh"
rdmssh is equivalent of classic ssh, but it can take passwords from Devolutions RemoteDesktopManager and use it in your ssh session

------------------------------------
INSTALL
------------------------------------

install using command
git clone git@github.com:MaskoSoitron/rdmssh.git

it will create rdmssh folder in current working dir
then
cd rdmssh && chmod +x ./rdmotp && chmod +x ./rdmssh && chmod +x ./install.sh && ./install.sh

------------------------------------
SETUP
------------------------------------
1. copy to ~/RDMExtras
mkdir -p ~/RDMExtras
cp rdmssh/* ~/RDMExtras

2. Add to bash_profile
vi ~/.bash_profile
export PATH="~/RDMExtras:$PATH"

3. Setup
rdmssh config
rdmssh help

-----------------------------------
USE
-----------------------------------
Usage: rdmssh username@address -p port
Port is optional...

Commands: - rdmssh command
  help: Show this help information.
  config: Set up initial configuration.
On first use, set up using 'rdmssh config'.
Supported ssh options: -p port
-----------------------------------
