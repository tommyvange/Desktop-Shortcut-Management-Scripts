################################################################################
# Repository: tommyvange/Desktop-Shortcut-Management-Scripts
# File: check_shortcut.ps1
# Developer: Tommy Vange Rød
# License: GPL 3.0 License
#
# This file is part of "Desktop Shortcut Management Scripts".
#
# "Desktop Shortcut Management Scripts" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html#license-text>.
################################################################################

param (
    [string]$ShortcutName,
    [switch]$Logging,
    [switch]$CommonDesktop
)

# Manually fill these variables if using ex. Intune (Intune does not support CLI args or config files with check scripts)
# $ManualShortcutName = "MyShortcut"
# $ManualCommonDesktop = $false  # Set to $true for Common Desktop, $false for User Desktop
# $ManualLogging = $false  # Set to $true to enable logging

# Path to configuration file
$configFilePath = "$PSScriptRoot\config.json"

# Initialize configuration variable
$config = $null

# Check if configuration file exists and load it
if (Test-Path $configFilePath) {
    $config = Get-Content -Path $configFilePath | ConvertFrom-Json
}

# Prioritize manually set variables
if ($ManualShortcutName) { $ShortcutName = $ManualShortcutName }
if ($ManualCommonDesktop) { $CommonDesktop = $ManualCommonDesktop }
if ($ManualLogging) { $Logging = $ManualLogging }

# Use parameters from the command line or fall back to config file values if not manually set
if (-not $ShortcutName) { $ShortcutName = $config.ShortcutName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }
if (-not $CommonDesktop) { $CommonDesktop = $config.CommonDesktop }

# Validate that the shortcut name is provided
if (-not $ShortcutName) { Write-Error "ShortcutName is required but not provided."; exit 1 }

# Determine log file path
$logFilePath = "$env:TEMP\desktop_shortcut_check_log_$ShortcutName.txt"

# Start transcript logging if enabled
if ($Logging) {
    Start-Transcript -Path $logFilePath
}

try {
    if ($CommonDesktop) {
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("CommonDesktopDirectory"), "$ShortcutName.lnk")
    } else {
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$ShortcutName.lnk")
    }

    # Check if the shortcut exists
    if (Test-Path $desktopPath) {
        Write-Output "Detected"
        exit 0
    } else {
        Write-Output "NotDetected"
        exit 1
    }
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Stop transcript logging if enabled
    if ($Logging) {
        Stop-Transcript
    }
}
