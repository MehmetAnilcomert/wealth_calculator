<#
.SYNOPSIS
    GitLab CI/CD Otomatik Deploy Script'i
.DESCRIPTION
    Bu script, main branch'indeki kodlari otomatik olarak gitlab-deploy
    branch'ine merge eder, belirtilen tag'i atar ve GitLab'a gondererek
    pipeline'i tetikler. Islem bitince sizi main branch'ine dondurur.
.EXAMPLE
    .\deploy.ps1 v1.0.5
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Lutfen bir surum tag'i girin (Orn: v1.0.0)")]
    [string]$Tag
)

$ErrorActionPreference = "Continue" # Git stderr (bilgi mesajlari) hata sayilmasin diye Continue yapildi

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🚀 GitLab Otomatik Deploy Baslatiliyor..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Surum: $Tag" -ForegroundColor Yellow
Write-Host ""


try {
    # 1. Bekleyen degisiklik var mi kontrol et
    $status = git status --porcelain
    if ($status) {
        Write-Host "HATA: Commitlenmemis degisiklikleriniz var!" -ForegroundColor Red
        Write-Host "Lutfen once 'main' branch'indeki degisikliklerinizi commit edin." -ForegroundColor Yellow
        exit 1
    }

    # 2. Hangi branch'te oldugumuzu bul
    $currentBranch = (git branch --show-current).Trim()
    if ($currentBranch -ne "main") {
        Write-Host "HATA: Su anda '$currentBranch' branch'indesiniz. Bu script sadece 'main' branch'inden calistirilmalidir." -ForegroundColor Red
        exit 1
    }

    # 3. Islemler
    Write-Host "[1/5] gitlab-deploy branch'ine geciliyor..." -ForegroundColor Gray
    cmd /c "git checkout gitlab-deploy"
    if ($LASTEXITCODE -ne 0) { throw "git checkout gitlab-deploy" }

    Write-Host "[2/5] main branch'indeki kodlar merge ediliyor..." -ForegroundColor Gray
    cmd /c "git merge main --no-edit"
    if ($LASTEXITCODE -ne 0) { throw "git merge main" }

    Write-Host "[3/5] Tag ($Tag) olusturuluyor..." -ForegroundColor Gray
    cmd /c "git tag $Tag"
    if ($LASTEXITCODE -ne 0) { throw "git tag $Tag" }

    Write-Host "[4/5] GitLab'a gonderiliyor (Pipeline tetiklenecek)..." -ForegroundColor Gray
    cmd /c "git push gitlab gitlab-deploy"
    if ($LASTEXITCODE -ne 0) { throw "git push gitlab gitlab-deploy" }
    
    cmd /c "git push gitlab $Tag"
    if ($LASTEXITCODE -ne 0) { throw "git push gitlab $Tag" }

    Write-Host "[5/5] Ana branch'e (main) geri donuluyor..." -ForegroundColor Gray
    cmd /c "git checkout main"
    if ($LASTEXITCODE -ne 0) { throw "git checkout main" }

    Write-Host ""
    Write-Host "✅ ISLEM BASARILI!" -ForegroundColor Green
    Write-Host "GitLab'da pipeline'iniz tetiklendi. Sonucu web arayuzunden takip edebilirsiniz." -ForegroundColor Cyan

} catch {
    Write-Host ""
    Write-Host "❌ BIR HATA OLUSTU:" -ForegroundColor Red
    Write-Host "Basarisiz komut: $_" -ForegroundColor Yellow
    Write-Host "Ana branch'e donulmeye calisiliyor..." -ForegroundColor Gray
    cmd /c "git checkout main"
}
