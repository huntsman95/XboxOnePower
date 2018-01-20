function checkForPowerOn(){
    Param(
        [parameter(Mandatory=$true)][string]$IPAddress
    )

    $Ping = New-Object System.Net.NetworkInformation.Ping
    if($(($ping.Send($IPAddress)).Status) -eq "Success"){
        $obj = New-Object -TypeName psobject -Property @{"IPAddress" = $IPAddress; "Action" = "PowerOn"; "Status" = "Success"; "Message" = "The Xbox at $IPAddress has been powered on"}
        return $obj
        #return $("The Xbox at " + $IPAddress + " has been powered on")
    }
    else
    {
        $obj = New-Object -TypeName psobject -Property @{"IPAddress" = $IPAddress; "Action" = "PowerOn"; "Status" = "Failed"; "Message" = "The Xbox at $IPAddress could not be powered on. Please check the IP and Live ID and try again."}
        return $obj
        #return $("The Xbox at " + $IPAddress + " could not be powered on. Please check the IP and Live ID and try again.")
    }
}

function checkForValidIP(){
Param(
[parameter(Mandatory=$true)][string]$IP
)
    try{
        if([ipaddress]$IP){return $true}
    }
    catch{
        return $false
    }
}

function Invoke-XboxOnePower {
<#

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


#>
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$true)][string] $LiveID="<XBOX ONE LIVE ID>",
      [parameter(Mandatory=$true)][string] $IP="<XBOX IP ADDRESS>",  
      [parameter(Mandatory=$false)][int] $port=5050
    )

    if(!(checkForValidIP -IP $IP)){throw "IP Address is invalid!"}
    else{[ipaddress]$ipAddress = $IP}

    $endpoint = New-Object System.Net.IPEndPoint($ipAddress, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient

    #([System.Text.Encoding]::ASCII.GetBytes($LiveID))
    [byte[]]$powerpayload = 0x00,([byte]$LiveID.Length) + ([System.Text.Encoding]::ASCII.GetBytes($LiveID)) + 0x00
    [byte[]]$powerheader = 0xdd,0x02,0x00 + [byte[]]$powerpayload.Length + 0x00,0x00
    
    $encodedData = $powerheader + $powerpayload

    for($i=0; $i -le 5; $i++){
        $bytesSent=$udpClient.Send($encodedData,$encodedData.length,$endpoint)
        Write-Progress -Activity "Waking up Xbox One" -Status $("Sending Packet " + ($i + 1) + " of 6") -PercentComplete (($i/6)*100)
        Start-Sleep -Seconds 1
    }

    $udpClient.Close()

    checkForPowerOn -IPAddress $IP
}

Export-ModuleMember -Function Invoke-XboxOnePower