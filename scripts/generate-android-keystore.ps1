param(
  [string]$Alias = "upload",
  [string]$AppName = "tringo_owner",
  [string]$OutDir = (Join-Path $env:USERPROFILE ".keys\$AppName"),
  [string]$KeystoreName = "upload.jks",
  [int]$ValidityDays = 10000,
  [string]$DistinguishedName = "CN=Tringo Owner, OU=Mobile, O=Fenizo, L=Chennai, S=TN, C=IN",
  [string]$StorePassword = "",
  [string]$KeyPassword = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-RandomPassword {
  param([int]$Length = 32)
  $bytes = New-Object byte[] ($Length)
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  # URL-safe base64-ish (no / + =) and trim to length
  $raw = [Convert]::ToBase64String($bytes) -replace "[/+=]", ""
  if ($raw.Length -lt $Length) { $raw = ($raw + $raw) }
  return $raw.Substring(0, $Length)
}

function Find-Keytool {
  $cmd = Get-Command keytool -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Path }

  $candidates = @()
  if ($env:JAVA_HOME) {
    $candidates += (Join-Path $env:JAVA_HOME "bin\\keytool.exe")
    $candidates += (Join-Path $env:JAVA_HOME "bin\\keytool")
  }

  $candidates += @(
    "C:\\Program Files\\Android\\Android Studio\\jbr\\bin\\keytool.exe",
    "C:\\Program Files (x86)\\Android\\Android Studio\\jbr\\bin\\keytool.exe"
  )

  $javaRoots = @("C:\\Program Files\\Java", "C:\\Program Files (x86)\\Java")
  foreach ($root in $javaRoots) {
    if (Test-Path $root) {
      Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $candidates += (Join-Path $_.FullName "bin\\keytool.exe")
      }
    }
  }

  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return $c }
  }
  return $null
}

$keytoolPath = Find-Keytool
if (-not $keytoolPath) {
  throw "keytool not found. Install a JDK (set JAVA_HOME) or use Android Studio bundled JBR. Then re-run this script."
}

if ([string]::IsNullOrWhiteSpace($StorePassword)) { $StorePassword = New-RandomPassword 40 }
if ([string]::IsNullOrWhiteSpace($KeyPassword)) { $KeyPassword = New-RandomPassword 40 }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$keystorePath = Join-Path $OutDir $KeystoreName

if (Test-Path $keystorePath) {
  throw "Keystore already exists: $keystorePath`nRefusing to overwrite. Move/rename it or choose a different -KeystoreName."
}

& $keytoolPath `
  -genkeypair `
  -v `
  -keystore $keystorePath `
  -storetype JKS `
  -alias $Alias `
  -keyalg RSA `
  -keysize 2048 `
  -validity $ValidityDays `
  -dname $DistinguishedName `
  -storepass $StorePassword `
  -keypass $KeyPassword | Out-Null

if (-not (Test-Path $keystorePath)) {
  throw "Keystore generation failed; expected file not found: $keystorePath"
}

# Lock down the keystore to the current user (best-effort)
try {
  & icacls $keystorePath /inheritance:r /grant:r "$($env:USERNAME):(R,W)" | Out-Null
} catch {
  # ignore ACL failures (e.g., non-NTFS)
}

$androidDir = Join-Path $PSScriptRoot "..\\android"
$propsPath = Join-Path $androidDir "key.properties"

# Gradle/Java can read forward slashes fine on Windows; avoids escaping backslashes.
$keystorePathForGradle = ($keystorePath -replace "\\\\", "/")

$props = @"
storeFile=$keystorePathForGradle
storePassword=$StorePassword
keyAlias=$Alias
keyPassword=$KeyPassword
"@

Set-Content -Path $propsPath -Value $props -NoNewline -Encoding UTF8

Write-Host "Created keystore: $keystorePath"
Write-Host "Wrote: $propsPath"
Write-Host "IMPORTANT: Back up the keystore file + passwords securely (password manager). If you lose it, you cannot update the same Play Store app unless Play App Signing is enabled."

