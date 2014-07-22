#!/ MCFLY YOU BOJO! YOU KNOW HOVERBOARDS DON'T FLOAT ON WATER!
#   UNLESS YOU'VE GOT POWER!!!!.... shell
#
# Kalabox Uninstall Script.
#
# Copyright (C) 2014 Kalamuna LLC
#
# This file will uninstall the underlying dependencies required to run
# kalastack-docker.
#

# Stop and Remove Kalabox
$vb = Get-WmiObject -Class win32_product | where { $_.Name -like "*VirtualBox*"}
$b2d = ${env:ProgramFiles} + '\Boot2Docker for Windows\boot2docker.exe'
If ((Test-Path $b2d) -and $vb) {
    Write-Output "Stopping Kalabox..."
    & $b2d poweroff
    Write-Output "Removing Kalabox..."
    & $b2d delete
    Sleep 5
}

# Uninstalling VirtualBox
# @todo no
if ($vb) {
    Write-Output "Uninstalling VirtualBox..."
    $arguments = "/uninstall $($vb.IdentifyingNumber) /quiet /norestart"  
    Start-Process -Wait -Verb RunAs msiexec $arguments
    Sleep 1
    Write-Output "Uninstalled VirtualBox!"
}

# Uninstalling MySYS
# @todo no prompts for this
$mysys_uninstaller = ${env:ProgramFiles(x86)} + '\Git\unins000.exe'
If (Test-Path $mysys_uninstaller) {
    Write-Output "Uninstalling MYSYS..."
    $arguments = "/SILENT /VERYSILENT /SUPRESSMSGBOXES /NORESTART"
    Start-Process -Wait $mysys_uninstaller $arguments
    Sleep 1
    Write-Output "Uninstalled MYSYS!"
}

# Uninstalling Boot2Docker
# @todo no prompts for this
$b2d_dir = ${env:ProgramFiles} + '\Boot2Docker for Windows'
$b2d_uninstaller = ${env:ProgramFiles} + '\Boot2Docker for Windows\unins000.exe'
If (Test-Path $b2d_uninstaller) {
    Write-Output "Uninstalling Boot2Docker..."
    $arguments = "/SILENT /VERYSILENT /SUPRESSMSGBOXES /NORESTART"
    Start-Process -Wait $b2d_uninstaller $arguments
    Sleep 1
    # For some reason this dir remains after install but is empty
    If (Test-Path $b2d_dir) {
        Remove-Item $b2d_dir -recurse
    }
    Write-Output "Uninstalled Boot2Docker!"
}

# Cleanup remaining files
$b2d_conf_folder = ${env:userprofile} + '\.boot2docker'
If (Test-Path $b2d_conf_folder) {
    Remove-Item $b2d_conf_folder -recurse
    Write-Output "Removed boot2docker profile and images."
}
$vm_conf_path = ${env:userprofile} + '\Virtual Box VMs\Kalabox'
If (Test-Path $vm_conf_path) {
    Remove-Item $vm_conf_path -recurse
    Write-Output "Removed Kalabox VM files"
}
# Uninstall Compelte
Write-Output "Kalabox uninstalled succesfully!"
