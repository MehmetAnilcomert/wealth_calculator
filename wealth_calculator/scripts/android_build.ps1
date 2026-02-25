# Proje dizinini al (parametre, script parent veya current directory)
param(
    [string]$ProjectPath = ""
)

Write-Host "=== Flutter Android Build Script ===" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($ProjectPath)) {
    # Eger parametre verilmemisse, script'in parent klasorunu dene
    if ($MyInvocation.MyCommand.Path) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $ProjectPath = Split-Path -Parent $scriptDir
    } else {
        # Script yolu bulunamazsa current directory kullan
        $ProjectPath = (Get-Location).Path
    }
}

# Flutter projesini dogrula
if (-not (Test-Path "$ProjectPath\pubspec.yaml")) {
    Write-Host "HATA: Bu bir Flutter projesi degil!" -ForegroundColor Red
    Write-Host "pubspec.yaml bulunamadi: $ProjectPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Kullanim: .\android_build.ps1 [-ProjectPath <path>]" -ForegroundColor Cyan
    exit 1
}

$projectName = (Get-Item $ProjectPath).Name
Write-Host ">>> Proje: $projectName" -ForegroundColor Green
Write-Host ">>> Dizin: $ProjectPath" -ForegroundColor Gray
Write-Host ""

# Google Play yükleme kontrolü ve version artırma
Write-Host "Google Play'e yuklenecek mi? (Version otomatik artacak)" -ForegroundColor Yellow
$uploadToPlay = Read-Host "Google Play'e yukle? (E/H)"

if ($uploadToPlay -eq "E" -or $uploadToPlay -eq "e") {
    Write-Host ""
    Write-Host ">>> Version artiriliyor..." -ForegroundColor Cyan
    
    # pubspec.yaml'i oku
    $pubspecPath = "$ProjectPath\pubspec.yaml"
    $pubspecContent = Get-Content $pubspecPath -Raw -Encoding UTF8
    
    # Mevcut versiyonu bul (format: version: 1.0.0+1)
    if ($pubspecContent -match 'version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)') {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        $patch = [int]$Matches[3]
        $buildNumber = [int]$Matches[4]
        
        $oldVersion = "$major.$minor.$patch+$buildNumber"
        
        # Version artırma seçenekleri
        Write-Host "Mevcut version: $oldVersion" -ForegroundColor White
        Write-Host ""
        Write-Host "Hangi versiyonu artirmak istersiniz?" -ForegroundColor Yellow
        Write-Host "1. Build Number (+1) -> $major.$minor.$patch+$($buildNumber + 1) [Kucuk duzeltmeler]" -ForegroundColor Gray
        Write-Host "2. Patch (0.0.+1) -> $major.$minor.$($patch + 1)+$($buildNumber + 1) [Bug fix]" -ForegroundColor Gray
        Write-Host "3. Minor (0.+1.0) -> $major.$($minor + 1).0+$($buildNumber + 1) [Yeni ozellikler]" -ForegroundColor Gray
        Write-Host "4. Major (+1.0.0) -> $($major + 1).0.0+$($buildNumber + 1) [Buyuk degisiklikler]" -ForegroundColor Gray
        Write-Host ""
        
        $versionChoice = Read-Host "Seciminiz (1-4, Enter=1)"
        if ([string]::IsNullOrEmpty($versionChoice)) { $versionChoice = "1" }
        
        switch ($versionChoice) {
            "1" {
                # Sadece build number artır
                $buildNumber++
            }
            "2" {
                # Patch artır, build number artır
                $patch++
                $buildNumber++
            }
            "3" {
                # Minor artır, patch sıfırla, build number artır
                $minor++
                $patch = 0
                $buildNumber++
            }
            "4" {
                # Major artır, minor ve patch sıfırla, build number artır
                $major++
                $minor = 0
                $patch = 0
                $buildNumber++
            }
            default {
                # Default: sadece build number
                $buildNumber++
            }
        }
        
        $newVersion = "$major.$minor.$patch+$buildNumber"
        
        # pubspec.yaml'i güncelle (regex ile)
        $newContent = $pubspecContent -replace "version:\s+\d+\.\d+\.\d+\+\d+", "version: $newVersion"
        
        # Dosyaya yaz (UTF8 encoding ile)
        [System.IO.File]::WriteAllText($pubspecPath, $newContent, [System.Text.UTF8Encoding]::new($false))
        
        Write-Host ""
        Write-Host "OK: Version guncellendi: $oldVersion -> $newVersion" -ForegroundColor Green
        Write-Host ""
        
        # Doğrulama
        Start-Sleep -Milliseconds 500
        $verifyContent = Get-Content $pubspecPath -Raw
        if ($verifyContent -match "version:\s+$newVersion") {
            Write-Host "OK: Degisiklik dogrulandi!" -ForegroundColor Green
        } else {
            Write-Host "UYARI: Version guncellemesi dogrulanamadi!" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "UYARI: Version bulunamadi veya format hatali!" -ForegroundColor Yellow
        Write-Host "Beklenen format: version: 1.0.0+1" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host ""

# Build tipi secimi
Write-Host "Build tipi secin:" -ForegroundColor Yellow
Write-Host "1. AAB (Android App Bundle) - Google Play icin onerilen" -ForegroundColor Green
Write-Host "2. APK (Android Package) - Direkt kurulum icin" -ForegroundColor Green
Write-Host "3. APK Split (ABI'lara gore ayri APK'lar)" -ForegroundColor Green
Write-Host ""

$choice = Read-Host "Seciminiz (1-3)"

Set-Location $ProjectPath

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
        flutter build appbundle --release
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            $outputFile = "$ProjectPath\build\app\outputs\bundle\release\app-release.aab"
            $fileName = "$projectName-$(Get-Date -Format 'yyyy-MM-dd').aab"
        }
    }
    "2" {
        Write-Host "APK build yapiliyor..." -ForegroundColor Cyan
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            $outputFile = "$ProjectPath\build\app\outputs\flutter-apk\app-release.apk"
            $fileName = "$projectName-$(Get-Date -Format 'yyyy-MM-dd').apk"
        }
    }
    "3" {
        Write-Host "Split APK build yapiliyor..." -ForegroundColor Cyan
        flutter build apk --split-per-abi --release
        if ($LASTEXITCODE -eq 0) {
            $buildSuccess = $true
            # Split icin klasor kopyalayacagiz
            $outputFile = "$ProjectPath\build\app\outputs\flutter-apk\"
            $fileName = "$projectName-split-$(Get-Date -Format 'yyyy-MM-dd')"
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