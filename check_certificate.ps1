param (
    [string]$certPath = "Cert:\LocalMachine\My",
    [string]$certName,
    [int]$warningDays = 30,
    [int]$criticalDays = 10,
    [switch]$help,
    [switch]$version
)

function Show-Help {
    "Usage: check_certificate.ps1 -certPath <cert_store_path> -certName <cert_name> -warningDays <warning_threshold> -criticalDays <critical_threshold>"
    "Options:"
    " -certPath           Path for certificates store (default: My -Personal-)"
    " -certName           Common name of certificate to check"
    " -warningDays        Warning expiration threshold (in days, default: 30)"
    " -criticalDays       Critical expiration threshold (in days, default: 10)"
    " -h                  Show this help"
    " -v                  Script version"
    exit
}

function Show-Version {
    "check_certificate.ps1 - John Gonzalez - version 1.0.0"
    exit
}

if ($help) { Show-Help }
if ($version) { Show-Version }
if (-not $certName) { "Error: -certName argument is required."; Show-Help }

$cert = Get-ChildItem -Path $certPath | Where-Object {$_.Subject -like "*CN=$certName*"} | Select-Object -First 1

if ($cert -ne $null) {
    $expDate = $cert.NotAfter
    $daysToExpire = New-TimeSpan -Start (Get-Date) -End $expDate
    $daysToExpire = $daysToExpire.Days

    if ($daysToExpire -le $criticalDays) {
        Write-Output "CRITICAL: Certificate '$certName' will expire in $daysToExpire days."
        exit 2
    } elseif ($daysToExpire -le $warningDays) {
        Write-Output "WARNING: Certificate '$certName' will expire in $daysToExpire days."
        exit 1
    } else {
        Write-Output "OK: Certificate '$certName' will expire in $daysToExpire days."
        exit 0
    }
} else {
    Write-Output "UNKNOWN: Certificate '$certName' not found."
    exit 3
}
