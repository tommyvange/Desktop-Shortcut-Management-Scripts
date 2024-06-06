# Desktop Shortcut Management Scripts

These scripts are designed to add, remove, and check desktop shortcuts on Windows machines for all users. They can read parameters from the command line, a configuration file (config.json), or use default values. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

This repository is licensed under the **[GNU General Public License v3.0 (GPLv3)](LICENSE)**.

Developed by **[Tommy Vange Rød](https://github.com/tommyvange)**.

## Configuration

The scripts use a configuration file (`config.json`) to store default values for the shortcut settings. Here is an example of the configuration file:

Web icon:
``` json
{
    "ShortcutName": "MyShortcut",
    "ShortcutUrl": "https://www.example.com",
    "IconUrl": "https://www.example.com/icon.ico",
    "Logging": false,
    "CommonDesktop": false
}
```
Local icon:
``` json
{
    "ShortcutName": "MyShortcut",
    "ShortcutUrl": "https://www.example.com",
    "IconUrl": "./icon.ico",
    "Logging": false,
    "CommonDesktop": false
}
```
No icon:
``` json
{
    "ShortcutName": "MyShortcut",
    "ShortcutUrl": "https://www.example.com",
    "Logging": false,
    "CommonDesktop": false
}
```

## Add Shortcut Script

### Description

The add shortcut script creates a desktop shortcut for all users using the specified parameters. If an icon URL is provided, the script will download the icon and apply it to the shortcut. The icon URL can be a web URL or a local path. For local paths, it will be resolved relative to the script directory.

### Usage
To run the add shortcut script, use the following command:

``` powershell
.\add_shortcut.ps1 -ShortcutName "<ShortcutName>" -ShortcutUrl "<ShortcutUrl>" [-IconUrl "<IconUrl>"] [-Logging] [-CommonDesktop]
```

### Parameters
- `ShortcutName`: The name of the shortcut.
- `ShortcutUrl`: The URL that the shortcut points to.
- [Optional] `IconUrl`: The URL to the icon file (.ico) to be used for the shortcut (can be a web URL or local path).
- [Optional] `Logging`: Enables transcript logging if set. Default is false.
- [Optional] `CommonDesktop`: Creates the shortcut on the common (public) desktop if set. Default is false (user's desktop).

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:

``` powershell
.\add_shortcut.ps1 -ShortcutName "MyShortcut" -ShortcutUrl "https://www.example.com" [-IconUrl "https://www.example.com/icon.ico"] [-Logging] [-CommonDesktop]
```

To use the default values from the configuration file:

``` powershell
.\add_shortcut.ps1
```

### Script Workflow
1.  Check if the shortcut name and URL are provided.
2.  Start transcript logging if enabled.
3.  Create the shortcut on the specified desktop (user's or common).
4.  If an icon URL is provided, download the icon if it's a web URL or resolve it if it's a local path.
5.  Apply the icon to the shortcut if available.

## Remove Shortcut Script

### Description
The remove shortcut script removes a specified desktop shortcut.

### Usage
To run the remove shortcut script, use the following command:

``` powershell
.\remove_shortcut.ps1 -ShortcutName "<ShortcutName>" [-Logging] [-CommonDesktop]
```

### Parameters
- `ShortcutName`: The name of the shortcut to remove.
- [Optional] `Logging`: Enables transcript logging if set.
- [Optional] `CommonDesktop`: Removes the shortcut from the common (public) desktop if set. Default is false (user's desktop).

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:

``` powershell
.\remove_shortcut.ps1 -ShortcutName "MyShortcut" [-Logging] [-CommonDesktop]
```

To use the default values from the configuration file:

``` powershell
.\remove_shortcut.ps1
```

### Script Workflow
1.  Check if the shortcut name is provided.
2.  Start transcript logging if enabled.
3.  Remove the shortcut from the specified desktop (user's or common) if it exists.

## Check Shortcut Script

### Description
The check shortcut script verifies if a specified desktop shortcut exists on the specified desktop (user's or common) and outputs "Detected" or "NotDetected". It uses exit codes compatible with Intune: `0` for success (detected) and `1` for failure (not detected).

### Usage
To run the check shortcut script, use the following command:

``` powershell
.\check_shortcut.ps1 -ShortcutName "<ShortcutName>" [-Logging] [-CommonDesktop]
```

### Parameters
- `ShortcutName`: The name of the shortcut to check.
- [Optional] `Logging`: Enables transcript logging if set.
- [Optional] `CommonDesktop`: Checks for the shortcut on the common (public) desktop if set. Default is false (user's desktop).

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:
``` powershell
.\check_shortcut.ps1 -ShortcutName "MyShortcut" [-Logging] [-CommonDesktop]
``` 

To use the default values from the configuration file:

``` powershell
.\check_shortcut.ps1
``` 

### Script Workflow
1.  Check if the shortcut name is provided.
2.  Start transcript logging if enabled.
3.  Check if the shortcut exists on the specified desktop (user's or common).
4.  Output "Detected" if the shortcut exists, otherwise output "NotDetected".

## Logging

### Description

All the scripts support transcript logging to capture detailed information about the script execution. Logging can be enabled via the `-Logging` parameter or the configuration file.

### How It Works

When logging is enabled, the scripts will start a PowerShell transcript at the beginning of the execution and stop it at the end. This transcript will include all commands executed and their output, providing a detailed log of the script's actions.

### Enabling Logging

Logging can be enabled by setting the `-Logging` parameter when running the script, or by setting the `Logging` property to `true` in the `config.json` file.

### Log File Location

The log files are stored in the temporary directory of the user running the script. The log file names follow the pattern:

-   For the add shortcut script: `desktop_shortcut_add_log_<ShortcutName>.txt`
-   For the remove shortcut script: `desktop_shortcut_remove_log_<ShortcutName>.txt`
-   For the check shortcut script: `desktop_shortcut_check_log_<ShortcutName>.txt`

Example log file paths:

-   `C:\Users\<Username>\AppData\Local\Temp\desktop_shortcut_add_log_MyShortcut.txt`
-   `C:\Users\<Username>\AppData\Local\Temp\desktop_shortcut_remove_log_MyShortcut.txt`
-   `C:\Users\<Username>\AppData\Local\Temp\desktop_shortcut_check_log_MyShortcut.txt`

**System Account Exception**: When scripts are run as the System account, such as during automated deployments or via certain administrative tools, the log files will be stored in the `C:\Windows\Temp` directory instead of the user's local temporary directory.

### Example
To enable logging via the command line:

``` powershell
.\add_shortcut.ps1 -ShortcutName "MyShortcut" -ShortcutUrl "https://www.example.com" -IconUrl "https://www.example.com/icon.ico" -Logging
```

Or by setting the `Logging` property in the configuration file:
``` json
{
    "ShortcutName": "MyShortcut",
    "ShortcutUrl": "https://www.example.com",
    "IconUrl": "https://www.example.com/icon.ico",
    "Logging": true,
	"CommonDesktop": false
}
```
## Error Handling

All scripts include error handling to provide clear messages when parameters are missing or actions fail. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

## Notes

-   Ensure that you have the necessary permissions to add, remove, and check shortcuts on the specified desktop (user's or common).

## Troubleshooting

If you encounter any issues, ensure that all parameters are correctly specified. Check the error messages provided by the scripts for further details on what might have gone wrong.

# GNU General Public License v3.0 (GPLv3)

The  **GNU General Public License v3.0 (GPLv3)**  is a free, copyleft license for software and other creative works. It ensures your freedom to share, modify, and distribute all versions of a program, keeping it free software for everyone.

Full license can be read [here](LICENSE) or at [gnu.org](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text).

## Key Points:

1.  **Freedom to Share and Change:**
    -   You can distribute copies of GPLv3-licensed software.
    -   Access the source code.
    -   Modify the software.
    -   Create new free programs using parts of it.
	
2.  **Responsibilities:**
    -   If you distribute GPLv3 software, pass on the same freedoms to recipients.
    -   Provide the source code.
    -   Make recipients aware of their rights.
	
3.  **No Warranty:**
    -   No warranty for this free software.
    -   Developers protect your rights through copyright and this license.
	
4.  **Marking Modifications:**
    -   Clearly mark modified versions to avoid attributing problems to previous authors.

