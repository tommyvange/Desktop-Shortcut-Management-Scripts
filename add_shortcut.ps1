################################################################################
# Repository: tommyvange/Desktop-Shortcut-Management-Scripts
# File: add_shortcut.ps1
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
    [string]$ShortcutUrl,
    [string]$IconUrl,
    [switch]$Logging,
    [switch]$CommonDesktop
)

# Initialize configuration variable
$config = $null

# Path to configuration file
$configFilePath = "$PSScriptRoot\config.json"

# Check if configuration file exists and load it
if (Test-Path $configFilePath) {
    $config = Get-Content -Path $configFilePath | ConvertFrom-Json
}

# Use parameters from the command line or fall back to config file values
if (-not $ShortcutName) { $ShortcutName = $config.ShortcutName }
if (-not $ShortcutUrl) { $ShortcutUrl = $config.ShortcutUrl }
if (-not $IconUrl) { $IconUrl = $config.IconUrl }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }
if (-not $CommonDesktop) { $CommonDesktop = $config.CommonDesktop }

# Validate that all parameters are provided
if (-not $ShortcutName) { Write-Error "ShortcutName is required but not provided."; exit 1 }
if (-not $ShortcutUrl) { Write-Error "ShortcutUrl is required but not provided."; exit 1 }

# Determine log file path
$logFilePath = "$env:TEMP\desktop_shortcut_add_log_$ShortcutName.txt"

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
    
    # Create the shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($desktopPath)
    $shortcut.TargetPath = $ShortcutUrl

    # Handle the icon URL
    if ($IconUrl) {
        # Determine persistent icon path in ProgramData
        $iconFolderPath = [System.IO.Path]::Combine($env:ProgramData, "DesktopIcons")
        if (-not (Test-Path $iconFolderPath)) {
            New-Item -ItemType Directory -Path $iconFolderPath | Out-Null
        }
        $iconPath = [System.IO.Path]::Combine($iconFolderPath, "$($ShortcutName).ico")

        if ($IconUrl -match '^https?://') {
            # Download the icon from the web
            try {
                Invoke-WebRequest -Uri $IconUrl -OutFile $iconPath -UseBasicParsing
            } catch {
                Write-Error "Failed to download icon from $IconUrl"
                exit 1
            }
        } else {
            # Assume local path and resolve with $PSScriptRoot
            $localIconPath = [System.IO.Path]::Combine($PSScriptRoot, $IconUrl)
            if (Test-Path (Resolve-Path $localIconPath)) {
                Copy-Item -Path (Resolve-Path $localIconPath) -Destination $iconPath -Force
            } else {
                Write-Error "Icon file does not exist: $localIconPath"
                exit 1
            }
        }
        $shortcut.IconLocation = $iconPath
    }

    $shortcut.Save()

    Write-Output "Shortcut '$ShortcutName' created successfully on the desktop."
    exit 0
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Stop transcript logging if enabled
    if ($Logging) {
        Stop-Transcript
    }
}
