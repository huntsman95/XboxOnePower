function Invoke-XboxOnePower {
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$true)][string] $LiveID="<XBOX ONE LIVE ID>",
      [parameter(Mandatory=$true)][string] $IP="<XBOX IP ADDRESS>",  
      [parameter(Mandatory=$false)][int] $port=5050
    )

    $ipAddress = $null
    $parseResult = [System.Net.IPAddress]::TryParse($IP, [ref] $ipAddress)

    if ( $parseResult -eq $false ) 
    {
        $IPes = [System.Net.Dns]::GetHostAddresses($IP)
        
        if ( $IPes -eq $null ) 
        {
            throw "Unable to resolve address: $IP"
        }

        $ipAddress = $IPes[0]
    }    

    $endpoint = New-Object System.Net.IPEndPoint($ipAddress, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient

    [byte[]]$payload=0xdd,0x02,0x00,0x13,0x00,0x00,0x00,0x10
    [byte[]]$payload2=0x00

    $encodedData= $payload + [System.Text.Encoding]::ASCII.GetBytes($LiveID) + $payload2
    $bytesSent=$udpClient.Send($encodedData,$encodedData.length,$endpoint)

    $udpClient.Close()
}