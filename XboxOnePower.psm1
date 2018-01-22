#Requires –Version 3

function checkForPowerOn(){
    Param(
        [parameter(Mandatory=$true)][string]$IPAddress
    )

    $regex = "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    if((($ip -split $regex)[4]) -eq "255"){
        $CIDRcheck = $((Get-NetIPAddress | where {$_.InterfaceIndex -eq (Get-NetIPConfiguration | Select-Object -ExpandProperty ipv4defaultgateway).ifIndex -and $_.AddressFamily -eq "IPv4"}).PrefixLength)
        if($CIDRcheck -eq "24"){
            return (Write-Host -ForegroundColor Yellow "Cannot verify power state of Xbox One due to the use of a broadcast address")
        }
    }

    $Ping = New-Object System.Net.NetworkInformation.Ping
    if($(($ping.Send($IPAddress)).Status) -eq "Success"){
        $obj = New-Object -TypeName psobject -Property ([ordered]@{"IPAddress" = $IPAddress; "Action" = "PowerOn"; `
                "Status" = "Success"; "Message" = "The Xbox at $IPAddress has been powered on"})
        return $obj
    }
    else
    {
        $obj = New-Object -TypeName psobject -Property ([ordered]@{"IPAddress" = $IPAddress; "Action" = "PowerOn"; `
                "Status" = "Failed"; "Message" = "The Xbox at $IPAddress could not be powered on. Please check the IP and Live ID and try again."})
        return $obj
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

This script supports the use of a 'config.json' file with variables: 'LiveID' and 'IP' to permit the execution of this script, sans-parameters.
This is useful in a home-automation scenario where specifying parameters might add complexity.


#>
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$false)][string] $LiveID,
      [parameter(Mandatory=$false)][string] $IP,  
      [parameter(Mandatory=$false)][int] $port=5050
    )

    if($LiveID -eq "" -and $IP -eq ""){
        if(Test-Path $($PSScriptRoot + "\config.json")){
            $config_tmp = Get-Content ($PSScriptRoot + "\config.json") | ConvertFrom-Json
            $LiveID = $config_tmp.LiveID
            $IP = $config_tmp.IP
        }
        if($LiveID -eq $null -or $LiveID -eq ""){$LiveID = Read-Host -Prompt "Please enter the Xbox Live Device ID of your Xbox One"}
        if($IP -eq $null -or $IP -eq ""){$IP = Read-Host -Prompt "Please enter the IP of your Xbox One"}
    }

    if(!(checkForValidIP -IP $IP)){throw "IP Address is invalid!"}
    else{[ipaddress]$ipAddress = $IP}

    $endpoint = New-Object System.Net.IPEndPoint($ipAddress, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient

    [byte[]]$powerpayload = 0x00,([byte]$LiveID.Length) + ([System.Text.Encoding]::ASCII.GetBytes($LiveID)) + 0x00
    [byte[]]$powerheader = 0xdd,0x02,0x00 + [byte[]]$powerpayload.Length + 0x00,0x00
    
    $encodedData = $powerheader + $powerpayload

    for($i=0; $i -le 5; $i++){
        $bytesSent=$udpClient.Send($encodedData,$encodedData.length,$endpoint)
        Write-Progress -Activity "Waking up Xbox One" -Status $("Sending Packet " + ($i + 1) + " of 6") -PercentComplete ((($i+1)/6)*100)
        Start-Sleep -Seconds 1
    }

    $udpClient.Close()

    checkForPowerOn -IPAddress $IP
}

Export-ModuleMember -Function Invoke-XboxOnePower