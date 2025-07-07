# Params / constants
$AppFolder = "build\windows\x64\runner\Release"
$PackageName = "28976LachapelleSoftware.FredStalker"
$DisplayName = "FredStalker"
$Publisher = "CN=D7F3F5FA-82AF-4A01-ACE9-073CE4F7FFA9"
$PublisherDisplayName = "Lachapelle Software"
$Executable = "fredstalker.exe"
$Version = "1.0.0.0"
$OutputFolder = "packaging/output/msix"
$OutputMsix = Join-Path $OutputFolder "FredStalker.msix"
$MakeAppxPath = "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe"
$PackageTemp = Join-Path $env:TEMP "msix_package"
$AssetsFolder = Join-Path $PackageTemp "Assets"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

if (Test-Path $PackageTemp) { Remove-Item $PackageTemp -Recurse -Force }
New-Item -ItemType Directory -Path $PackageTemp | Out-Null

Copy-Item "$AppFolder\*" $PackageTemp -Recurse
if (-not (Test-Path $AssetsFolder)) {
    New-Item -ItemType Directory -Path $AssetsFolder | Out-Null
}
Copy-Item "packaging/store-logo.png" (Join-Path $AssetsFolder "StoreLogo.png") -Force
Copy-Item "packaging/150x150Logo.png" (Join-Path $AssetsFolder "Square150x150Logo.png") -Force
Copy-Item "packaging/44x44Logo.png" (Join-Path $AssetsFolder "Square44x44Logo.png") -Force

$ManifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"
  IgnorableNamespaces="uap">

  <Identity
    Name="$PackageName"
    Publisher="$Publisher"
    Version="$Version" />

  <Properties>
    <DisplayName>$DisplayName</DisplayName>
    <PublisherDisplayName>$PublisherDisplayName</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
  </Properties>

  <Resources>
    <Resource Language="en-us"/>
  </Resources>

  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.19041.0" MaxVersionTested="10.0.19041.0" />
  </Dependencies>

  <Applications>
    <Application Id="App"
                 Executable="$Executable"
                 EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements
        DisplayName="$DisplayName"
        Square150x150Logo="Assets\Square150x150Logo.png"
        Square44x44Logo="Assets\Square44x44Logo.png"
        Description="The best Stalker IPTV app"
        BackgroundColor="transparent"/>
    </Application>
  </Applications>

  <Capabilities>
    <Capability Name="internetClient"/>
    <rescap:Capability Name="runFullTrust"/>
  </Capabilities>
</Package>
"@

Set-Content -Path (Join-Path $PackageTemp "AppxManifest.xml") -Value $ManifestContent -Encoding UTF8


# Package to MSIX
& "$MakeAppxPath" pack /d $PackageTemp /p $OutputMsix /o

Write-Host "MSIX package created at $OutputMsix (unsigned, ready for Store signing)"
