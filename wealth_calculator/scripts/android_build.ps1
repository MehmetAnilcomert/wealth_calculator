Write-Host "=== Wealth Calculator Android Build Script ===" -ForegroundColor Cyan
Write-Host ""

# Build tipi secimi
Write-Host "Build tipi secin:" -ForegroundColor Yellow
Write-Host "1. AAB (Android App Bundle) - Google Play icin onerilen" -ForegroundColor Green
Write-Host "2. APK (Android Package) - Direkt kurulum icin" -ForegroundColor Green
Write-Host "3. APK Split (ABI'lara gore ayri APK'lar)" -ForegroundColor Green
Write-Host ""

$choice = Read-Host "Seciminiz (1-3)"

# Script'in bulundugu yeri bul ve proje dizinine git
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = Split-Path -Parent $scriptDir
Set-Location $projectPath

Write-Host ""
Write-Host ">>> Proje dizini: $projectPath" -ForegroundColor Gray
Write-Host ""
Write-Host ">>> Flutter Clean yapiliyor..." -ForegroundColor Yellow
flutter clean

if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Flutter clean basarisiz!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host ">>> Dependencies aliniyor..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "UYARI: Pub get tamamlanamadi ama devam ediyoruz..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "NOT: Symlink hatasi aliyorsaniz, Developer Mode'u acin:" -ForegroundColor Cyan
    Write-Host "     Komut: start ms-settings:developers" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Devam etmek istiyor musunuz? (E/H)"
    if ($continue -ne "E" -and $continue -ne "e") {
        Write-Host "Islem iptal edildi." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host ">>> Build basliyor (bu birkac dakika surebilir)..." -ForegroundColor Yellow
Write-Host ""

# Build komutunu çalıştır
$buildSuccess = $false
$outputFile = ""
$fileName = ""

switch ($choice) {
    "1" {
        Write-Host "AAB build yapiliyor..." -ForegroundColor Cyan
        flutter build appbundle --release --no-tree-shake-icons
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            $outputFile = "$projectPath\build\app\outputs\bundle\release\app-release.aab"
            $fileName = "wealth-calculator-$(Get-Date -Format 'yyyy-MM-dd').aab"
        }
    }
    "2" {
        Write-Host "APK build yapiliyor..." -ForegroundColor Cyan
        flutter build apk --release --no-tree-shake-icons
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            $outputFile = "$projectPath\build\app\outputs\flutter-apk\app-release.apk"
            $fileName = "wealth-calculator-$(Get-Date -Format 'yyyy-MM-dd').apk"
        }
    }
    "3" {
        Write-Host "Split APK build yapiliyor..." -ForegroundColor Cyan
        flutter build apk --split-per-abi --release --no-tree-shake-icons
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            # Split icin klasor kopyalayacagiz
            $outputFile = "$projectPath\build\app\outputs\flutter-apk\"
            $fileName = "wealth-calculator-split-$(Get-Date -Format 'yyyy-MM-dd')"
        }
    }
    default {
        Write-Host "Gecersiz secim!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

if ($buildSuccess -and (Test-Path $outputFile)) {
    Write-Host "OK: Build basarili!" -ForegroundColor Green
    Write-Host ""
    
    # Masaustu yolu
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    
    if ($choice -eq "3") {
        # Split APK için klasör oluştur
        $destFolder = Join-Path $desktopPath $fileName
        New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
        
        # Tüm APK dosyalarını kopyala
        Copy-Item "$outputFile\*.apk" -Destination $destFolder -Force
        
        $fileCount = (Get-ChildItem "$destFolder\*.apk").Count
        Write-Host ">>> $fileCount APK dosyasi masaustune kopyalandi:" -ForegroundColor Cyan
        Write-Host "    $destFolder" -ForegroundColor White
        
        # Dosyaları listele
        Get-ChildItem "$destFolder\*.apk" | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host "    - $($_.Name) (${sizeMB} MB)" -ForegroundColor Gray
        }
    } else {
        # Tek dosya kopyala
        $destFile = Join-Path $desktopPath $fileName
        Copy-Item $outputFile -Destination $destFile -Force
        
        $fileSize = (Get-Item $destFile).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
        
        Write-Host ">>> Dosya masaustune kopyalandi:" -ForegroundColor Cyan
        Write-Host "    $destFile" -ForegroundColor White
        Write-Host "    Boyut: ${fileSizeMB} MB" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "OK: Islem tamamlandi!" -ForegroundColor Green
    Write-Host ""
    
    if ($choice -eq "1") {
        Write-Host "Google Play Console'a yuklemek icin AAB dosyasini kullanin." -ForegroundColor Yellow
    } else {
        Write-Host "APK dosyasini Android cihaziniza yukleyebilirsiniz." -ForegroundColor Yellow
    }
    
    # Masaustunu ac
    Write-Host ""
    $openDesktop = Read-Host "Masaustunu acmak ister misiniz? (E/H)"
    if ($openDesktop -eq "E" -or $openDesktop -eq "e") {
        Start-Process "explorer.exe" $desktopPath
    }
    
} else {
    Write-Host "HATA: Build basarisiz!" -ForegroundColor Red
    Write-Host "Yukaridaki hata mesajlarini kontrol edin." -ForegroundColor Red
    exit 1
}