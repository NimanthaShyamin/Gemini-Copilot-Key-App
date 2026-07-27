[Setup]
AppName=Gemini Co-Pilot Key App
AppVersion=1.0.5.0
AppPublisher=GeminiCopilotKeyApp
OutputBaseFilename=GeminiCopilot_Installer
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
Source: "Gemini Co-Pilot Key App.msix"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "GeminiCopilotKeyApp.pfx"; DestDir: "{tmp}"; Flags: ignoreversion

[Run]
; 1. Install the Certificate silently into TrustedPeople using Windows CertUtil
Filename: "certutil.exe"; Parameters: "-f -p ""#pgj2rvlpr"" -importpfx ""TrustedPeople"" ""{tmp}\GeminiCopilotKeyApp.pfx"""; Flags: runhidden waituntilterminated

; 2. Install the MSIX package silently using PowerShell
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -WindowStyle Hidden -Command ""Add-AppxPackage -Path '{tmp}\Gemini Co-Pilot Key App.msix'"""; Flags: runhidden waituntilterminated