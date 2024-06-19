# DayZ Standalone Server Setup on Windows

## Introduction

This guide provides a step-by-step process to install and set up a DayZ Standalone server on a Windows computer or server.

## Prerequisites

Before you begin, ensure you have the following:

- A Windows computer/server
- A [Steam](https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe) account (Steam will auto-download when you click the link)
- [Notepad++](https://notepad-plus-plus.org/downloads/) installed
- A fresh install of DayZ Server.

## Steps

### 1. Download and Install Steam

Download and Install Steam:
- [Download Steam](https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe)
- Follow the installation instructions and log in with your Steam account.

### 2. Download and Install the DayZ Server

Download and Install the DayZ Server:
- Open Steam.
- Navigate to LIBRARY > TOOLS.
- Find DayZ Server in the list, right-click it, and click Install game.
- Choose your download location and agree to the terms.

Locate Server Files:
- Navigate to the installation directory, by default: `C:\Program Files (x86)\Steam\steamapps\common\DayZServer`.

### 3. Download the startup Script

Download the Batch File:
- [Download launcher.bat](https://github.com/MoreKronos/Advanced-DayZ-Server-Launcher/archive/refs/tags/Dayz.zip)
- Place `launcher.bat` inside your DayZ server folder (e.g., `C:\Program Files (x86)\Steam\steamapps\common\DayZServer`).

### 4. Configure the Server

Edit `serverDZ.cfg`:
- Navigate to the server directory and open `serverDZ.cfg`.
- Edit it to your preferences and save the changes.
- Documentation for `serverDZ.cfg` can be found [here](https://community.bistudio.com/wiki/DayZ:Server_Configuration).

### 5. Open Ports

Open Windows Firewall:
- Open Windows Firewall with Advanced Security.
- Right-click Inbound Rules and click New Rule....

Create a New Port Rule:
- Select Port.
- Choose UDP and enter `2302-2305` in the specified local ports.
- Ensure Allow the connection is selected.
- Apply the rule to your network and name it DayZ Server.

### 6. Start the Server

Run the Batch File:
- Double-click `launcher.bat` to start the server.
- If you encounter errors, refer to the troubleshooting steps below.

### 7. Troubleshooting Common Errors

- **VCRuntime140.dll is missing**: Install the x64 Visual C++ Redistributable from [here](https://www.microsoft.com/en-us/download/details.aspx?id=52685).
- **XAPOFX1_5.dll and/or X3DAudio1_7.dll are missing**: Install the DirectX End-User Runtime from [here](https://www.microsoft.com/en-us/download/details.aspx?id=8109).

### 8. Connecting to Your Server

Use your server's IP address followed by the port, e.g., `127.0.0.1:2302`.

## Conclusion

You should now have a functional DayZ Standalone server. You can further customize your server by exploring various configuration options and mods.

## Additional Resources

- [DayZ Server Documentation 1](https://write.corbpie.com/installing-and-setting-up-a-dayz-standalone-server-on-windows-server-2016-guide/)
- [DayZ Server Documentation 2](https://pointandshooter.co.uk/dayz/how-to-setup-a-local-dayz-server-on-pc)
  
- [DayZ Server serverDZ.cfg Documentation](https://community.bistudio.com/wiki/DayZ:Server_Configuration)

## License

This project is licensed under the MIT License - [see the LICENSE file for details.](https://github.com/MoreKronos/Advanced-DayZ-Server-Launcher?tab=MIT-1-ov-file) 
