@echo off
:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :Admin
) else (
    echo Requesting Administrator permissions to safely install the certificate...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~dpnx0\"' -Verb RunAs"
    exit
)

:Admin
echo ---------------------------------------------------
echo Installing Gemini Co-Pilot Key App...
echo ---------------------------------------------------

set "DIR=%~dp0"
set "CERT=%DIR%GeminiCopilotKeyApp.pfx"
set "APP=%DIR%Gemini Co-Pilot Key App.msix"
set "PASS=#pgj2rvlpr"

echo 1. Installing Security Certificate to Trusted Root...
powershell -Command "$pwd = ConvertTo-SecureString -String '%PASS%' -Force -AsPlainText; Import-PfxCertificate -FilePath '%CERT%' -CertStoreLocation Cert:\LocalMachine\Root -Password $pwd | Out-Null"

echo.
echo 2. Launching App Installer...
start "" "%APP%"

echo.
echo Setup complete! Please click "Install" on the blue Windows pop-up.
pause