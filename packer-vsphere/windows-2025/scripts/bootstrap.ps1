$ErrorActionPreference = "Stop"

Write-Host "Bootstrap: configuring WinRM and firewall..."

winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM 5985" dir=in action=allow protocol=TCP localport=5985 | Out-Null
Set-Service WinRM -StartupType Automatic
Start-Service WinRM


