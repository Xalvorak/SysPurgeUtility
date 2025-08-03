Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "BITS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "DoSvc" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue

$envPaths = @(
    "$env:LOCALAPPDATA\Temp",
    "$env:TEMP",
    "$env:SystemRoot\Temp",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\WebCache",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer",
    "$env:USERPROFILE\AppData\Local\CrashDumps"
)

foreach ($path in $envPaths) {
    if (Test-Path $path) {
        Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

wevtutil el | ForEach-Object { wevtutil cl "$_" }

$wuCache = "$env:SystemRoot\SoftwareDistribution\Download"
if (Test-Path $wuCache) {
    Remove-Item "$wuCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}

$prefetch = "$env:SystemRoot\Prefetch"
if (Test-Path $prefetch) {
    Remove-Item "$prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
}

ipconfig /flushdns

$thumbCache = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer"
Get-ChildItem $thumbCache -Include *thumbcache* -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Get-ChildItem -Path "C:\" -Include *.bak -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

wsreset.exe

Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

cleanmgr /sagerun:1
$cleanmgrKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
Get-ChildItem $cleanmgrKey | ForEach-Object {
    Set-ItemProperty -Path "$cleanmgrKey\$_" -Name StateFlags001 -Value 2 -ErrorAction SilentlyContinue
}
Start-Process -FilePath cleanmgr.exe -ArgumentList '/sagerun:1' -Wait

Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
Start-Service -Name "BITS" -ErrorAction SilentlyContinue
Start-Service -Name "DoSvc" -ErrorAction SilentlyContinue
Start-Service -Name "SysMain" -ErrorAction SilentlyContinue

Write-Host "Nettoyage complet terminé." -ForegroundColor Green
