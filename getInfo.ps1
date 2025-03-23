param (
    [string]$Token
)
Write-Output "Token: $Token"

$Token1 = Read-Host "Please enter your Token1:"
Write-Host "Token1: $Token1"


$computerName = ""
try {
	$computerName = hostname
} catch {
	Write-Host "Error: $_"
}

$osInfo = ""
try {
	$osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, WindowsBuildLabEx, OSArchitecture, OsName
} catch {
	Write-Host "Error: $_"
}

$cpuInfo = ""
try {
	$cpuInfo = Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
} catch {
	Write-Host "Error: $_"
}

$ramInfo = ""
try {
	$ramInfo = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)
} catch {
	Write-Host "Error: $_"
}

$privateIP = ""
try {
	$privateIP = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.PrefixOrigin -ne "Manual" -and $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress
} catch {
	Write-Host "Error: $_"
}
# $publicIP = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()

$macAddress = ""
try {
	# $macAddress = Get-NetAdapter | Select-Object Name, MacAddress
	$macAddress = Get-NetAdapter | Select-Object Name, MacAddress | Where-Object {-not [string]::IsNullOrEmpty($_.MacAddress)}
	# $macAddress = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1).MacAddress
} catch {
	Write-Host "Error: $_"
}

$disk = ""
try {
	# Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::round($_.Used/1GB, 2)}}, @{Name="Free(GB)";Expression={[math]::round($_.Free/1GB, 2)}}, @{Name="Total(GB)";Expression={[math]::round($_.Used + $_.Free / 1GB, 2)}}
	$disk = Get-Disk | Select-Object Number, FriendlyName, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}
} catch {
	Write-Host "Error: $_"
}

$body = @{
	"computerName" = $computerName
	"osInfo" = $osInfo
	"cpuInfo" = $cpuInfo
	"ramInfo" = $ramInfo
	"privateIP" = $privateIP
	"macAddress" = $macAddress
	"disk" = $disk
	"token" = $Token
} | ConvertTo-Json

Write-Output $body

$apiUrl = "http://localhost:10025/api/v1/test"

try {
    # Send POST request
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
    $response
}
catch {
    Write-Host "Lỗi khi gửi request: $_"
	# Write-Host "Ghi vào File"
	# $macAddress | Out-File -FilePath "D:\mac_address.txt"
	# Write-Host "Đã lưu MAC Address vào file D:\mac_address.txt"
}
