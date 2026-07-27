$baseDir = $PSScriptRoot

Write-Host "1. Publishing the .NET 8 Application..." -ForegroundColor Cyan
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "$baseDir\PublishOutput"

Write-Host "2. Preparing Manifest and Assets..." -ForegroundColor Cyan
Copy-Item -Path "$baseDir\AppxManifest.xml" -Destination "$baseDir\PublishOutput\AppxManifest.xml" -Force

$assetsDir = "$baseDir\PublishOutput\Assets"
if (!(Test-Path $assetsDir)) { New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null }

# Check for custom icon
$customIconPath = "$baseDir\icon.png"
if (Test-Path $customIconPath) {
    Copy-Item -Path $customIconPath -Destination "$assetsDir\StoreLogo.png" -Force
    Copy-Item -Path $customIconPath -Destination "$assetsDir\Square150x150Logo.png" -Force
    Copy-Item -Path $customIconPath -Destination "$assetsDir\Square44x44Logo.png" -Force
    Write-Host "-> Custom icon.png successfully applied!" -ForegroundColor Green
}
else {
    Write-Host "-> Warning: icon.png not found! Using invisible fallback." -ForegroundColor Yellow
    $transparentPngB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
    $pngBytes = [System.Convert]::FromBase64String($transparentPngB64)
    [System.IO.File]::WriteAllBytes("$assetsDir\StoreLogo.png", $pngBytes)
    [System.IO.File]::WriteAllBytes("$assetsDir\Square150x150Logo.png", $pngBytes)
    [System.IO.File]::WriteAllBytes("$assetsDir\Square44x44Logo.png", $pngBytes)
}

Write-Host "3. Locating Windows SDK Tools..." -ForegroundColor Cyan
$sdkBinPath = "C:\Program Files (x86)\Windows Kits\10\bin"
$makeAppxPath = (Get-ChildItem -Path $sdkBinPath -Filter "makeappx.exe" -Recurse | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName
$signToolPath = (Get-ChildItem -Path $sdkBinPath -Filter "signtool.exe" -Recurse | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName

if (!$makeAppxPath -or !$signToolPath) {
    Write-Error "Could not find makeappx.exe or signtool.exe."
    exit
}

Write-Host "4. Packing the MSIX..." -ForegroundColor Cyan
$msixPath = "$baseDir\Gemini Co-Pilot Key App.msix"
if (Test-Path $msixPath) { Remove-Item $msixPath -Force }
& $makeAppxPath pack -d "$baseDir\PublishOutput" -p $msixPath | Out-Null

Write-Host "5. Signing the MSIX..." -ForegroundColor Cyan
$certPath = "$baseDir\GeminiCopilotKeyApp.pfx"
if (!(Test-Path $certPath)) {
    Write-Host "-> ERROR: Certificate ($certPath) is missing! Signing aborted." -ForegroundColor Red
    exit
}

& $signToolPath sign /v /fd SHA256 /f $certPath /p "#pgj2rvlpr" $msixPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS! Your app is packaged and properly signed at: $msixPath" -ForegroundColor Green
}
else {
    Write-Host "`nERROR: Signing failed. Please check the error above." -ForegroundColor Red
}