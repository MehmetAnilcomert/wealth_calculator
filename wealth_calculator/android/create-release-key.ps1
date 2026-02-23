Write-Host "=== Wealth Calculator Release Key Olusturucu ===" -ForegroundColor Green
Write-Host ""

$storePassword = Read-Host "Key store sifresi girin (en az 6 karakter)"
$keyPassword = Read-Host "Key sifresi girin (en az 6 karakter)"

if ($storePassword.Length -lt 6 -or $keyPassword.Length -lt 6) {
    Write-Host "HATA: Sifreler en az 6 karakter olmali!" -ForegroundColor Red
    exit 1
}

$keyPropertiesContent = "storePassword=$storePassword`nkeyPassword=$keyPassword`nkeyAlias=wealth-calculator`nstoreFile=wealth-calculator-key.jks"
Set-Content -Path "key.properties" -Value $keyPropertiesContent
Write-Host "OK: key.properties olusturuldu" -ForegroundColor Green

Write-Host ""
Write-Host "Keystore dosyasi olusturuluyor..." -ForegroundColor Yellow
Write-Host ""

keytool -genkey -v -keystore wealth-calculator-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wealth-calculator -storepass $storePassword -keypass $keyPassword

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "OK: Keystore basariyla olusturuldu!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Simdi 'flutter build apk' komutunu calistirabilirsiniz." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "HATA: Keystore olusturulamadi!" -ForegroundColor Red
}
