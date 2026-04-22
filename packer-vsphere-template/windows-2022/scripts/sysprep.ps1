$ErrorActionPreference = "Stop"

Write-Host "Running sysprep..."
& "$env:SystemRoot\System32\Sysprep\Sysprep.exe" /oobe /generalize /shutdown /quiet

