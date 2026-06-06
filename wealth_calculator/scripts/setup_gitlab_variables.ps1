<#
.SYNOPSIS
    GitLab CI/CD Variables Otomatik Tanımlama Script'i
.DESCRIPTION
    Bu script, wealth_calculator projesinin GitLab CI/CD pipeline'ı için
    gerekli olan 3 ortam değişkenini otomatik olarak GitLab'a yükler.
    
    Gereksinimler:
    - glab CLI kurulu olmalı (choco install glab -y)
    - glab auth login ile giriş yapılmış olmalı
    - Keystore dosyası mevcut olmalı
    - Play Store JSON dosyası mevcut olmalı
.NOTES
    Kullanım: .\setup_gitlab_variables.ps1
#>

param(
    [string]$JsonKeyPath,
    [string]$KeystorePath = "..\android\wealth-calculator-key.jks",
    [string]$KeyPropertiesPath = "..\android\key.properties"
)

$ErrorActionPreference = "Stop"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitLab CI/CD Variables Kurulum Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ─── 1. glab CLI Kontrolü ───
Write-Host "[1/6] glab CLI kontrol ediliyor..." -ForegroundColor Yellow
$glabCmd = Get-Command glab -ErrorAction SilentlyContinue
if (-not $glabCmd) {
    Write-Host "  glab CLI bulunamadi. Kuruluyor..." -ForegroundColor Red
    choco install glab -y
    # PATH'i yenile
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $glabCmd = Get-Command glab -ErrorAction SilentlyContinue
    if (-not $glabCmd) {
        Write-Host "  HATA: glab kurulumu basarisiz. Terminali yeniden acip tekrar deneyin." -ForegroundColor Red
        exit 1
    }
}
Write-Host "  glab CLI bulundu: $($glabCmd.Source)" -ForegroundColor Green

# ─── 2. glab Auth Kontrolü ───
Write-Host "[2/6] GitLab oturum kontrol ediliyor..." -ForegroundColor Yellow
$authStatus = glab auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  GitLab'a giris yapilmamis. Simdi giris yapiliyor..." -ForegroundColor Red
    Write-Host "  Tarayicinizda acilan sayfada GitLab hesabinizla giris yapin." -ForegroundColor Cyan
    glab auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  HATA: GitLab girisi basarisiz." -ForegroundColor Red
        exit 1
    }
}
Write-Host "  GitLab oturumu aktif." -ForegroundColor Green

# ─── 3. Keystore Dosyası (Base64) ───
Write-Host "[3/6] Keystore dosyasi okunuyor..." -ForegroundColor Yellow

# Script dizinine göre yolu çöz
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Get-Location }
$keystoreFullPath = Resolve-Path (Join-Path $scriptDir $KeystorePath) -ErrorAction SilentlyContinue

if (-not $keystoreFullPath -or -not (Test-Path $keystoreFullPath)) {
    Write-Host "  Keystore dosyasi bulunamadi: $KeystorePath" -ForegroundColor Red
    $keystoreFullPath = Read-Host "  Keystore (.jks) dosyasinin tam yolunu girin"
    if (-not (Test-Path $keystoreFullPath)) {
        Write-Host "  HATA: Dosya bulunamadi: $keystoreFullPath" -ForegroundColor Red
        exit 1
    }
}

$keystoreBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystoreFullPath.ToString()))
Write-Host "  Keystore Base64'e donusturuldu ($([math]::Round($keystoreBase64.Length / 1024, 1)) KB)" -ForegroundColor Green

# ─── 4. Key Properties ───
Write-Host "[4/6] key.properties dosyasi okunuyor..." -ForegroundColor Yellow

$keyPropsFullPath = Resolve-Path (Join-Path $scriptDir $KeyPropertiesPath) -ErrorAction SilentlyContinue

if (-not $keyPropsFullPath -or -not (Test-Path $keyPropsFullPath)) {
    Write-Host "  key.properties bulunamadi: $KeyPropertiesPath" -ForegroundColor Red
    $keyPropsFullPath = Read-Host "  key.properties dosyasinin tam yolunu girin"
    if (-not (Test-Path $keyPropsFullPath)) {
        Write-Host "  HATA: Dosya bulunamadi: $keyPropsFullPath" -ForegroundColor Red
        exit 1
    }
}

$keyPropertiesContent = Get-Content $keyPropsFullPath.ToString() -Raw
Write-Host "  key.properties okundu." -ForegroundColor Green

# ─── 5. Play Store JSON Key ───
Write-Host "[5/6] Play Store JSON key dosyasi okunuyor..." -ForegroundColor Yellow

if ($JsonKeyPath -and (Test-Path $JsonKeyPath)) {
    $jsonKeyContent = Get-Content $JsonKeyPath -Raw
} else {
    Write-Host ""
    Write-Host "  Google Play Service Account JSON dosyasinin tam yolunu girin." -ForegroundColor Cyan
    Write-Host "  (Henuz olusturmadiysan, bu adimi 'SKIP' yazarak atlayabilirsiniz)" -ForegroundColor Gray
    $JsonKeyPath = Read-Host "  JSON dosya yolu (veya SKIP)"
    
    if ($JsonKeyPath -eq "SKIP" -or [string]::IsNullOrWhiteSpace($JsonKeyPath)) {
        Write-Host "  Play Store JSON key atlandi. Daha sonra GitLab arayuzunden ekleyebilirsiniz." -ForegroundColor Yellow
        $jsonKeyContent = $null
    } elseif (Test-Path $JsonKeyPath) {
        $jsonKeyContent = Get-Content $JsonKeyPath -Raw
        Write-Host "  JSON key okundu." -ForegroundColor Green
    } else {
        Write-Host "  HATA: Dosya bulunamadi: $JsonKeyPath" -ForegroundColor Red
        Write-Host "  Bu degiskeni daha sonra GitLab arayuzunden ekleyebilirsiniz." -ForegroundColor Yellow
        $jsonKeyContent = $null
    }
}

# ─── 6. GitLab'a Yükleme ───
Write-Host "[6/6] Degiskenler GitLab'a yukleniyor..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$totalCount = 0

# ANDROID_KEYSTORE_BASE64
$totalCount++
Write-Host "  [a] ANDROID_KEYSTORE_BASE64 yukleniyor..." -NoNewline
try {
    # Önce mevcut değişkeni silmeyi dene (güncelleme için)
    glab variable delete ANDROID_KEYSTORE_BASE64 2>$null
    glab variable set ANDROID_KEYSTORE_BASE64 "$keystoreBase64" --protected --masked 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " BASARILI" -ForegroundColor Green
        $successCount++
    } else {
        # masked olmadan dene (çok uzun değerler masked olamayabilir)
        glab variable set ANDROID_KEYSTORE_BASE64 "$keystoreBase64" --protected 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " BASARILI (masked desteği yok, protected olarak eklendi)" -ForegroundColor Yellow
            $successCount++
        } else {
            Write-Host " HATA" -ForegroundColor Red
        }
    }
} catch {
    Write-Host " HATA: $_" -ForegroundColor Red
}

# ANDROID_KEY_PROPERTIES
$totalCount++
Write-Host "  [b] ANDROID_KEY_PROPERTIES yukleniyor..." -NoNewline
try {
    glab variable delete ANDROID_KEY_PROPERTIES 2>$null
    glab variable set ANDROID_KEY_PROPERTIES "$keyPropertiesContent" --protected 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " BASARILI" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host " HATA" -ForegroundColor Red
    }
} catch {
    Write-Host " HATA: $_" -ForegroundColor Red
}

# PLAY_STORE_JSON_KEY
if ($jsonKeyContent) {
    $totalCount++
    Write-Host "  [c] PLAY_STORE_JSON_KEY yukleniyor..." -NoNewline
    try {
        glab variable delete PLAY_STORE_JSON_KEY 2>$null
        glab variable set PLAY_STORE_JSON_KEY "$jsonKeyContent" --protected 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " BASARILI" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " HATA" -ForegroundColor Red
        }
    } catch {
        Write-Host " HATA: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [c] PLAY_STORE_JSON_KEY atlandi (JSON dosyasi verilmedi)" -ForegroundColor Gray
}

# ─── Sonuç ───
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sonuc: $successCount/$totalCount degisken basariyla yuklendi" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $jsonKeyContent) {
    Write-Host "  NOT: PLAY_STORE_JSON_KEY daha sonra eklenmelidir." -ForegroundColor Yellow
    Write-Host "  GitLab > Settings > CI/CD > Variables sayfasindan ekleyebilirsiniz." -ForegroundColor Yellow
    Write-Host ""
}

# Doğrulama
Write-Host "Mevcut GitLab degiskenleri:" -ForegroundColor Cyan
glab variable list
