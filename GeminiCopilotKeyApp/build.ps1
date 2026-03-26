# build.ps1
$baseDir = $PSScriptRoot

Write-Host "1. Publishing the .NET 8 Application..." -ForegroundColor Cyan
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "$baseDir\PublishOutput"

Write-Host "2. Preparing Manifest and Assets..." -ForegroundColor Cyan
Copy-Item -Path "$baseDir\AppxManifest.xml" -Destination "$baseDir\PublishOutput\AppxManifest.xml" -Force

# Generate the transparent logo assets
$transparentPngB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
$pngBytes = [System.Convert]::FromBase64String($transparentPngB64)
$assetsDir = "$baseDir\PublishOutput\Assets"

if (!(Test-Path $assetsDir)) { New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null }

[System.IO.File]::WriteAllBytes("$assetsDir\StoreLogo.png", $pngBytes)
[System.IO.File]::WriteAllBytes("$assetsDir\Square150x150Logo.png", $pngBytes)
[System.IO.File]::WriteAllBytes("$assetsDir\Square44x44Logo.png", $pngBytes)

Write-Host "3. Locating Windows SDK Tools..." -ForegroundColor Cyan
$sdkBinPath = "C:\Program Files (x86)\Windows Kits\10\bin"
$makeAppxPath = (Get-ChildItem -Path $sdkBinPath -Filter "makeappx.exe" -Recurse | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName
$signToolPath = (Get-ChildItem -Path $sdkBinPath -Filter "signtool.exe" -Recurse | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName

if ([string]::IsNullOrEmpty($makeAppxPath) -or [string]::IsNullOrEmpty($signToolPath)) {
    Write-Error "Could not find makeappx.exe or signtool.exe. Please ensure the Windows 10 or 11 SDK is installed."
    exit
}

Write-Host "4. Packing the MSIX..." -ForegroundColor Cyan
$msixPath = "$baseDir\Gemini Co-Pilot Key App.msix"
if (Test-Path $msixPath) { Remove-Item $msixPath -Force }
& $makeAppxPath pack -d "$baseDir\PublishOutput" -p $msixPath

Write-Host "5. Signing the MSIX..." -ForegroundColor Cyan
& $signToolPath sign /a /v /fd SHA256 /f "$baseDir\GeminiCopilotKeyApp.pfx" /p "#pgj2rvlpr" $msixPath

Write-Host "`nSuccess! Your app is packaged and signed at: $msixPath" -ForegroundColor Green