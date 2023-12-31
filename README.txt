------------------------------------
Requirements: sshpass, powershell, Devolutions.Powershell module
------------------------------------

This tool allows you to use command "rdmssh" and "rdmotp"
rdmssh is equivalent of classic ssh, but it can take passwords from Devolutions RemoteDesktopManager and use it in your ssh session
rdmotp searches for all OTP credentials in you RDM client, and then prompts you which one you want to see and copy to your clipboard.
rdmotp assumes that all OTP credentials have name ending with "_otp", because there is no other automated way to differentiate standard username/password object and otp code object in RDM

------------------------------------
INSTALL & CONFIGURE
------------------------------------

install using command 
git clone git@github.com:MaskoSoitron/rdmcli.git

it will create rdmcli folder in current working dir
then
cd rdmcli && chmod +x ./rdmotp && chmod +x ./rdmssh && chmod +x ./install.sh && ./install.sh

rdmssh config
rdmssh help

-----------------------------------
USE - rdmssh command
-----------------------------------
Usage: rdmssh username@address -p port
Port is optional...

Commands: - rdmssh command
  help: Show this help information.
  config: Set up initial configuration.
On first use, set up using 'rdmssh config'.
Supported ssh options: -p port
-----------------------------------
USE - rdmotp command
-----------------------------------
Usage: rdmotp [command]
rdmotp command assumes that your OTP credential entries have _otp suffix in its name

If no command is provided, the script will list all OTP sessions in RDM. And prompt the user to choose one.
Commands: - rdmotp command
  help: Show this help information.
  config: Set up initial configuration.
  refresh: Refresh OTP cache.
Supported options: None
-----------------------------------
USE - rdmotpl command
-----------------------------------
Usage: rdmotpl [command]
This command looks for OTP credential entries in your local data source specified in rdm.conf
OTP entries must be in folder Root\OTP, an/or have _otp suffix in its name

If no command is provided, the script will list all OTP sessions in RDM. And prompt the user to choose one.
Commands: - rdmotp command
  help: Show this help information.
  config: Set up initial configuration.
  refresh: Refresh OTP cache.
Supported options: None
