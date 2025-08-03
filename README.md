# SysPurgeUtility.ps1

SysPurgeUtility is a powerful PowerShell script designed to perform a deep cleaning of Windows systems. It removes various caches, logs, temporary files, DNS cache, Windows Update leftovers, thumbnail caches, and more. The goal is to free disk space and improve system responsiveness on heavily used machines.

## Features

The script covers a wide range of cleanup tasks:

- Stops key Windows services that may lock files during cleanup (Windows Update, BITS, Delivery Optimization).
- Clears all user and system temporary folders including Windows temp, user temp, and cache directories.
- Removes Event Viewer logs to free up space and reduce clutter.
- Deletes leftover files from Windows Update downloads.
- Clears thumbnail and Explorer icon caches.
- Flushes DNS resolver cache.
- Cleans Prefetch folder to reset app preloading.
- Runs the built-in Windows Disk Cleanup tool (`cleanmgr`) silently with all options enabled.
- Removes `.bak` files from the system drive.
- Cleans up SoftwareDistribution folder to free update cache.
- Automatically restarts services after cleanup.

Warnings

Run the script as Administrator to allow all cleanup operations.

The script is aggressive and deletes files that Windows considers safe to remove.

Purging caches and logs can impact diagnostics or application load times temporarily.

Back up important data before running, and use at your own risk.

Usage
To run the script, open an elevated PowerShell prompt and execute:

.\SysPurgeUtility.ps1
If your system policy blocks script execution, enable it for the current user with:

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

## Key parts of the script

Here are some examples of the core commands used in the script:

```powershell
# Stop services that may lock files
Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "BITS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "DoSvc" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue

# Paths to clear
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

# Clear Event Viewer logs
wevtutil el | ForEach-Object { wevtutil cl "$_" }

# Flush DNS cache
ipconfig /flushdns

# Cleanup Windows Update leftovers
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Run Disk Cleanup silently
cleanmgr /sagerun:1
