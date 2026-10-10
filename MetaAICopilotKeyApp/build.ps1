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
    Write-Host "-> Warning: icon.png not found! Using fallback." -ForegroundColor Yellow
    $transparentPngB64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
    $pngBytes = [System.Convert]::FromBase64String($transparentPngB64)
    [System.IO.File]::WriteAllBytes("$assetsDir\StoreLogo.png", $pngBytes)
    [System.IO.File]::WriteAllBytes("$assetsDir\Square150x150Logo.png", $pngBytes)
    [System.IO.File]::WriteAllBytes("$assetsDir\Square44x44Logo.png", $pngBytes)
}

Write-Host "3. Locating Windows SDK Tools..." -ForegroundColor Cyan
$sdkBinPath = "C:\Program Files (x86)\Windows Kits\10\bin"
$makeAppxPath = (Get-ChildItem -Path $sdkBinPath -Filter "makeappx.exe" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName
$signToolPath = (Get-ChildItem -Path $sdkBinPath -Filter "signtool.exe" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -match "x64" } | Select-Object -First 1).FullName

if (!$makeAppxPath -or !$signToolPath) {
    Write-Error "Could not find makeappx.exe or signtool.exe in '$sdkBinPath'."
    exit
}

Write-Host "4. Packing the MSIX..." -ForegroundColor Cyan
$msixPath = "$baseDir\Meta AI Co-Pilot Key App.msix"
if (Test-Path $msixPath) { Remove-Item $msixPath -Force }
& $makeAppxPath pack -d "$baseDir\PublishOutput" -p $msixPath | Out-Null

Write-Host "5. Signing the MSIX..." -ForegroundColor Cyan
$certPath = "$baseDir\MetaAICopilotKeyApp.pfx"
if (!(Test-Path $certPath)) {
    Write-Host "-> Certificate not found. Automatically generating self-signed certificate..." -ForegroundColor Yellow
    $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=MetaAICopilotKeyApp" -KeyUsage DigitalSignature -FriendlyName "Meta AI Copilot Key App Cert" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
    $pwd = ConvertTo-SecureString -String "#pgj2rvlpr" -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $pwd | Out-Null
    Write-Host "-> Created $certPath" -ForegroundColor Green
}

& $signToolPath sign /v /fd SHA256 /f $certPath /p "#pgj2rvlpr" $msixPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS! Your app is packaged and properly signed at: $msixPath" -ForegroundColor Green

    # Optional: Build Inno Setup standalone single-click installer
    $isccPaths = @(
        "C:\Program Files\Inno Setup 7\ISCC.exe",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    )
    $iscc = $isccPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($iscc) {
        Write-Host "`n6. Compiling Inno Setup Single-Click Installer..." -ForegroundColor Cyan
        & $iscc "$baseDir\Inno SetupBuilder.iss"
        Write-Host "Installer generated in: $baseDir\Output" -ForegroundColor Green
    }
}
else {
    Write-Host "`nERROR: Signing failed. Please check the error above." -ForegroundColor Red
}