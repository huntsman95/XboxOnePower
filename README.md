# PS-XboxOnePower

.SYNOPSIS

Powers on an Xbox One in your local network

.DESCRIPTION

This script uses the IP address of your Xbox One and its 'Live ID' to send a specially crafted UDP packet to the Xbox designed to remotely power it on.  
This is the same way the Windows 10 'Xbox' app achieves this functionality.

.PARAMETER LiveID

The Xbox Live device ID of the Xbox One you want to power on


.PARAMETER IP

The IP Address of the Xbox One you want to power on

.EXAMPLE

Power on your Xbox One  
Invoke-XboxOnePower -LiveID ABCDEF1234567890 -IP 192.168.69.69

.NOTES

This script runs best on a local network (WAN functionality not guaranteed since my network is secure and doesn't support UPnP port forwarding).  
  
To get the LiveID of your Xbox One:  
1. Press the Xbox button on your controller to open the guide  
2. Select 'Settings'  
3. Under 'System', select 'Console info'  
4. The LiveID is under "Xbox Live device ID"
