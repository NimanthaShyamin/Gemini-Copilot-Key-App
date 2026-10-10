[Setup]
AppName=Meta AI Co-Pilot Key App
AppVersion=3.0
AppPublisher=MetaAICopilotKeyApp
OutputBaseFilename=MetaAICopilot_Installer
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
; We don't need Inno to make an app folder; we will use a temporary folder
CreateAppDir=no
; Windows MSIX handles the uninstall, so Inno doesn't need to make an uninstaller
Uninstallable=no
CreateUninstallRegKey=no

[Files]
; Extract the package and certificate to a temporary directory that auto-deletes later
Source: "Meta AI Co-Pilot Key App.msix"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "MetaAICopilotKeyApp.pfx"; DestDir: "{tmp}"; Flags: ignoreversion

[Run]
; 1. Install the Certificate silently into TrustedPeople using Windows CertUtil
Filename: "certutil.exe"; Parameters: "-f -p ""#pgj2rvlpr"" -importpfx ""TrustedPeople"" ""{tmp}\MetaAICopilotKeyApp.pfx"""; Flags: runhidden waituntilterminated

; 2. Install the MSIX package silently using PowerShell
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -WindowStyle Hidden -Command ""Add-AppxPackage -Path '{tmp}\Meta AI Co-Pilot Key App.msix'"""; Flags: runhidden waituntilterminated