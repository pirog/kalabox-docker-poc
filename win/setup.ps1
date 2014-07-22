#!/ MCFLY YOU BOJO! YOU KNOW HOVERBOARDS DON'T FLOAT ON WATER!
#   UNLESS YOU'VE GOT POWER!!!!.... shell
#
# Kalabox Install Script.
#
# Copyright (C) 2014 Kalamuna LLC
#
# This file will install the underlying dependencies required to run
# kalastack-docker.
#

# Download the Boot2Docker Windows installer
$temp_dir = $env:TMP
$url = "http://files.kalamuna.com/boot2docker-win-1.1.1.exe"
$file = "$temp_dir\docker-installer.exe"
If (Test-Path $file) {
    Write-Output "Already downloaded that installer thang!"
}
Else {
    $webclient = New-Object System.Net.WebClient
    Write-Output "Downloading Boot2Docker installer..."
    $webclient.DownloadFile($url,$file)
    Write-Output "Downloaded."
}

# Running a silent install of Boot2Docker but only if we are missing something
$b2d = ${env:ProgramFiles} + '\Boot2Docker for Windows\boot2docker.exe'
$mysys = ${env:ProgramFiles(x86)} + '\Git\bin\bash.exe'
$vb = Get-WmiObject -Class win32_product | where { $_.Name -like "*VirtualBox*"}
If (!(Test-Path $b2d) -or !(Test-Path $mysys) -or !$vb) {
    Write-Output "Installing Boot2Docker..."
    $arguments = '/SP /SILENT /VERYSILENT /SUPRESSMSGBOXES /NOCANCEL /NOREBOOT /NORESTART /CLOSEAPPLICATIONS /LOADINF="b2d.inf"'
    #Start-Process -Wait $file $arguments
    Start-Process -Wait $file $arguments
    Write-Output "Boot2Docker Installed!"
}

# Initialize and build Kalabox
$b2d_conf_folder = ${env:userprofile} + '\.boot2docker'
$b2d_dir = ${env:ProgramFiles} + '\Boot2Docker for Windows'
Write-Output "Moving in Kalabox config and ISO..."
If (!(Test-Path -Path $b2d_conf_folder)) {
    New-Item -Path $b2d_conf_folder -ItemType Directory
}
$scriptpath = $MyInvocation.MyCommand.Path
$script_dir = Split-Path $scriptpath
Copy-Item "$script_dir\profile" "$b2d_conf_folder\profile" -force
Copy-Item "$b2d_dir\boot2docker.iso" "$b2d_conf_folder\boot2docker.iso" -force
Write-Output "Initializing Kalabox..."
& $b2d init
Write-Output "Starting Kalabox..."
& $b2d start

# All Done!
Write-Output "Installation of dependencies complete!"


