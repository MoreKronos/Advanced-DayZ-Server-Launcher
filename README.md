DayZ Standalone Server Setup on Windows
Introduction
This guide provides a step-by-step process to install and set up a DayZ Standalone server on a Windows computer or server.

Prerequisites
Before you begin, ensure you have the following:

A Windows computer/server
A Steam account
Notepad++ installed
Steps
Download and Install Steam

Download and Install Steam:
Download Steam (this link will automatically download the installer).
Follow the installation instructions and log in with your Steam account.
Download and Install the DayZ Server

Download and Install the DayZ Server:
Open Steam.
Navigate to LIBRARY > TOOLS.
Find DayZ Server in the list, right-click it, and click Install game.
Choose your download location and agree to the terms.
Locate Server Files:
Navigate to the installation directory, by default: C:\Program Files (x86)\Steam\steamapps\common\DayZServer.
Create a Startup Script

Download the Batch File:
Download the launcher.bat file from here.
Place launcher.bat inside your DayZ server folder (e.g., C:\Program Files (x86)\Steam\steamapps\common\DayZServer).
Configure the Server

Edit serverDZ.cfg:
Navigate to the server directory and open serverDZ.cfg.
Edit it to your preferences and save the changes.
Documentation for serverDZ.cfg can be found here.
Open Ports

Open Windows Firewall:
Open Windows Firewall with Advanced Security.
Right-click Inbound Rules and click New Rule....
Create a New Port Rule:
Select Port.
Choose UDP and enter 2302-2305 in the specified local ports.
Ensure Allow the connection is selected.
Apply the rule to your network and name it DayZ Server.
Start the Server

Run the Batch File:
Double-click launcher.bat to start the server.
If you encounter errors, refer to the troubleshooting steps below.
Troubleshooting Common Errors

VCRuntime140.dll is missing:
Install the x64 Visual C++ Redistributable from here.
XAPOFX1_5.dll and/or X3DAudio1_7.dll are missing:
Install the DirectX End-User Runtime from here.
Connecting to Your Server

Use your server's IP address followed by the port, e.g., 127.0.0.1:2302.
Conclusion
You should now have a functional DayZ Standalone server. You can further customize your server by exploring various configuration options and mods.

Additional Resources
DayZ Server Documentation
License
This project is licensed under the MIT License - see the LICENSE file for details.
