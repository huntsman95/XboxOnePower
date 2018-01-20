# PS-XboxOnePower

.SYNOPSIS

Powers on an Xbox One in your local network

.DESCRIPTION

This script uses the IP address of your Xbox One and its 'Live ID' to send a specially crafted UDP packet to the Xbox designed to remotely power it on.
This is the same way the Windows 10 'Xbox' app achieves this functionality.

.PARAMETER LiveID

a single computer name or an array of computer names. You mayalso provide IP addresses.


.PARAMETER IP

The path and file name of a text file. Any computers that cannot be reached will be logged to this file. 
This is an optional parameter; if it is notincluded, no log file will be generated.

.EXAMPLE

Power on your Xbox One
Invoke-XboxOnePower -LiveID ABCDEF1234567890 -IP 192.168.69.69

.NOTES

This script runs best on a local network (WAN functionality not guaranteed since my network is secure and doesn't support UPnP port forwarding).

To get the LiveID of your Xbox One:
Press the Xbox button on your controller to open the guide.
Select Settings.
Select All Settings.
Under System, select Console info & updates.