param(
  [string]$Alias = "upload",
  # Default: keep artifacts inside the project (but git-ignored).
  [string]$OutDir = (Join-Path $PSScriptRoot "..\\android\\keystore"),
  [string]$KeyAlg = "RSA",
  [int]$KeySize = 2048,
  [int]$ValidityDays = 10000,
  [string]$DName = "CN=Upload Key, OU=Mobile, O=Fenizo, L=Unknown, S=Unknown, C=IN"
)

$ErrorActionPreference = "Stop"

function Resolve-KeytoolPath {
  $javaHome = $env:JAVA_HOME
  if ([string]::IsNullOrWhiteSpace($javaHome) -or -not (Test-Path -LiteralPath $javaHome)) {
    $javaHome = "C:\\Program Files\\Android\\Android Studio\\jbr"
  }
  $keytool = Join-Path $javaHome "bin\\keytool.exe"
  if (-not (Test-Path -LiteralPath $keytool)) {
    throw "keytool.exe not found at: $keytool. Set JAVA_HOME to a JDK/JRE that has keytool."
  }
  return $keytool
}

function SecureStringToPlainText([Security.SecureString]$secureString) {
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

$keytool = Resolve-KeytoolPath

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$keystorePath = Join-Path $OutDir "upload_reset_$timestamp.jks"
$pemPath = Join-Path $OutDir "upload_reset_$timestamp.pem"

Write-Host "This will create a NEW Play upload keystore and export its certificate (PEM)."
Write-Host "Keystore: $keystorePath"
Write-Host "PEM:      $pemPath"
Write-Host ""

$storeSecure = Read-Host "Enter a strong keystore password" -AsSecureString
$keySecure = Read-Host "Enter a strong key password (can be same)" -AsSecureString
$storePass = SecureStringToPlainText $storeSecure
$keyPass = SecureStringToPlainText $keySecure

Write-Host ""
Write-Host "Generating keystore..."
& $keytool -genkeypair `
  -v `
  -keystore $keystorePath `
  -storetype JKS `
  -alias $Alias `
  -keyalg $KeyAlg `
  -keysize $KeySize `
  -validity $ValidityDays `
  -dname $DName `
  -storepass $storePass `
  -keypass $keyPass | Out-Host

Write-Host ""
Write-Host "Exporting certificate to PEM..."
& $keytool -exportcert `
  -rfc `
  -keystore $keystorePath `
  -alias $Alias `
  -storepass $storePass | Set-Content -LiteralPath $pemPath -Encoding ascii

Write-Host ""
Write-Host "Upload key created."
Write-Host "Keystore: $keystorePath"
Write-Host "Alias:    $Alias"
Write-Host "PEM:      $pemPath"
Write-Host ""
Write-Host "Next:"
Write-Host "- In Play Console: App integrity -> Upload key -> Request upload key reset."
Write-Host "- Upload THIS PEM file when asked: $pemPath"
Write-Host "- After Google approves, update android/key.properties to point to this NEW keystore + passwords."
