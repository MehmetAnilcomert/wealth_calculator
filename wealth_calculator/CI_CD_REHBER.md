# GitLab CI/CD + Fastlane Play Store Deploy Pipeline Rehberi

> **Proje:** wealth_calculator (Flutter)  
> **Tarih:** 2026-06-06  
> **Yazar:** Anıl  

---

## 1. Mimari Genel Bakış

```
GitHub (origin)  ←→  Yerel Repo  ←→  GitLab (gitlab)
                                          │
                                     git tag push
                                          │
                                    CI/CD Pipeline
                                          │
                                   ┌──────┴──────┐
                                   │ Windows     │
                                   │ Runner      │
                                   │ (prod tag)  │
                                   └──────┬──────┘
                                          │
                                    Fastlane
                                          │
                                   Play Store
                                   Beta Track
```

**Dual-Remote:** Git birden fazla remote destekler. Proje hem GitHub hem GitLab'da tutulabilir:
- `git push origin main` → GitHub'a gönderir
- `git push gitlab main` → GitLab'a gönderir
- `git push gitlab v1.0.0` → Pipeline tetikler!

---

## 2. Gereksinimler (Windows)

| Araç | Kurulum | Amaç |
|---|---|---|
| Chocolatey | [chocolatey.org/install](https://community.chocolatey.org/install.ps1) | Paket yöneticisi |
| Ruby 3.4+ | `choco install ruby -y` | Fastlane çalışma ortamı |
| Java 17 | `choco install openjdk17 -y` | Android derleme |
| Git | `choco install git -y` | Versiyon kontrolü |
| Flutter SDK | [flutter.dev](https://flutter.dev) | Uygulama derleme |
| Android SDK | Flutter ile birlikte gelir | Android araçları |

### Ruby PATH ve Locale Ayarları

```powershell
# Ruby PATH (kalıcı)
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\tools\ruby34\bin", "User")

# UTF-8 locale (Fastlane gereksinimleri)
[System.Environment]::SetEnvironmentVariable("LC_ALL", "en_US.UTF-8", "User")
[System.Environment]::SetEnvironmentVariable("LANG", "en_US.UTF-8", "User")
```

---

## 3. Fastlane Kurulumu

### 3.1 Gem Kurulumu

```powershell
gem install fastlane -N
gem install multi_json   # Ruby 3.4+ için gerekli ek bağımlılık
```

### 3.2 Proje Dosyaları

**android/Gemfile:**
```ruby
source "https://rubygems.org"

gem "fastlane"
gem "multi_json"  # Fastlane'in Google API bağımlılığı için gerekli (Ruby 3.4+)
```

**android/fastlane/Appfile:**
```ruby
json_key_file(ENV["PLAY_STORE_JSON_KEY_PATH"] || "")
package_name("com.wealthcalc.app")
```

**android/fastlane/Fastfile:**
```ruby
default_platform(:android)

platform :android do
  desc "Play Store Beta'ya AAB Deploy"
  lane :deploy_to_playstore do

    # 1. Flutter ile release AAB üret
    sh("flutter", "build", "appbundle", "--release")

    # 2. Play Store beta track'ine yükle
    upload_to_play_store(
      track: "beta",
      json_key_data: ENV["PLAY_STORE_JSON_KEY"],
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
```

### 3.3 Bağımlılık Kilitleme

```powershell
cd android
bundle install        # Gemfile.lock oluşturur
bundle exec fastlane lanes  # Doğrulama
```

---

## 4. Google Play Console API Erişimi

1. [Google Play Console](https://play.google.com/console/) → **Setup → API Access**
2. Google Cloud projesi bağlayın
3. **Service Account** oluşturun (adı: `gitlab-ci-delivery`)
4. Rol: **Service Account User**
5. **Keys → Add Key → Create New Key → JSON** formatında indirin
6. Play Console'a dönüp hesaba **Release Manager** izni verin

> ⚠️ **DİKKAT:** İndirdiğiniz JSON dosyası Play Store kimliğinizdir. Git reposuna YÜKLEMEYIN!

---

## 5. Güvenlik — .gitignore Ayarları

Aşağıdaki satırları `.gitignore` dosyanıza ekleyin:

```gitignore
# Signing keys & secrets (CI/CD will generate these from GitLab Variables)
android/key.properties
android/*.jks
android/*.keystore

# Fastlane artifacts
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_result
**/fastlane/README.md
```

Eğer bu dosyalar zaten Git'te izleniyorsa:
```powershell
git rm --cached android/key.properties
git rm --cached android/wealth-calculator-key.jks
```

---

## 6. GitLab CI/CD Pipeline (.gitlab-ci.yml)

Proje kök dizininde oluşturun:

```yaml
stages:
  - deploy

variables:
  GRADLE_OPTS: "-Dorg.gradle.daemon=false"
  LC_ALL: "en_US.UTF-8"
  LANG: "en_US.UTF-8"

deploy_to_android:
  stage: deploy
  tags:
    - prod  # Windows Runner etiketiniz
  only:
    - tags  # Sadece git tag oluşturulduğunda tetiklenir
  except:
    - branches  # Normal push'larda çalışmaz
  script:
    # 1. Base64 keystore → fiziksel dosya (PowerShell)
    - '[System.Convert]::FromBase64String($env:ANDROID_KEYSTORE_BASE64) | Set-Content -Path android/wealth-calculator-key.jks -Encoding Byte'

    # 2. key.properties dosyasını oluştur
    - '$env:ANDROID_KEY_PROPERTIES | Set-Content -Path android/key.properties'

    # 3. Flutter bağımlılıkları
    - flutter pub get

    # 4. Fastlane ile deploy
    - cd android
    - bundle install
    - bundle exec fastlane deploy_to_playstore
```

---

## 7. GitLab Runner Kurulumu (Windows)

### 7.1 Kurulum

```powershell
choco install gitlab-runner -y
```

### 7.2 Token Alma

1. GitLab projeniz → **Settings → CI/CD → Runners**
2. **New project runner** → Platform: **Windows**, Tags: **prod**
3. Token'ı kopyalayın

### 7.3 Kayıt

```powershell
gitlab-runner register
# URL: https://gitlab.com/
# Token: (kopyaladığınız)
# Description: Windows_Android_Runner
# Tags: prod
# Executor: powershell
```

### 7.4 Servis Başlatma

```powershell
gitlab-runner start
```

> **ÖNEMLİ:** Runner'ın çalıştığı makinede Flutter SDK, Java 17, Android SDK ve Ruby+Fastlane PATH'te olmalıdır.

---

## 8. GitLab Variables Tanımlama

CI/CD pipeline'ın çalışması için 3 gizli değişkenin GitLab'a yüklenmesi gerekir. Bunu **iki yöntemle** yapabilirsiniz:

### Tanımlanması Gereken Değişkenler

| Değişken | İçerik | Protected | Masked |
|---|---|---|---|
| `PLAY_STORE_JSON_KEY` | Google Play Service Account JSON dosyasının **tam içeriği** | ✅ | ❌ |
| `ANDROID_KEYSTORE_BASE64` | `.jks` keystore dosyasının Base64 formatı | ✅ | ✅ |
| `ANDROID_KEY_PROPERTIES` | Gradle imzalama şifreleri (4 satır düz metin) | ✅ | ❌ |

> **Protected** = Sadece korumalı branch/tag'lerde kullanılır (güvenlik)  
> **Masked** = Pipeline loglarında `[MASKED]` olarak gizlenir

---

### Yöntem A: Otomatik Script ile (Önerilen) ⚡

Projede hazır bir PowerShell script'i bulunur: `scripts/setup_gitlab_variables.ps1`

#### Ön Koşullar

```powershell
# 1. glab CLI kurulumu (henüz yoksa)
choco install glab -y

# 2. GitLab'a giriş yapma (ilk seferde)
glab auth login
# Tarayıcıda açılan sayfada GitLab hesabınızla giriş yapın
```

#### Çalıştırma

```powershell
# Proje kök dizininden:
.\scripts\setup_gitlab_variables.ps1
```

Script otomatik olarak:
1. `android/wealth-calculator-key.jks` dosyasını bulup Base64'e çevirir
2. `android/key.properties` dosyasını okur
3. Play Store JSON dosya yolunu sorar (henüz yoksa SKIP yazarak atlayabilirsiniz)
4. Üç değişkeni de `glab variable set` komutuyla GitLab'a yükler
5. Sonuçları doğrular

#### Alternatif: Tek Tek Manuel glab Komutları

```powershell
# Base64 keystore üret ve değişkene ata
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("android\wealth-calculator-key.jks"))
glab variable set ANDROID_KEYSTORE_BASE64 "$base64" --protected

# key.properties içeriğini oku ve değişkene ata
$keyProps = Get-Content android\key.properties -Raw
glab variable set ANDROID_KEY_PROPERTIES "$keyProps" --protected

# Play Store JSON key (dosya yolunu kendi yolunuzla değiştirin)
$jsonKey = Get-Content "C:\yol\service-account.json" -Raw
glab variable set PLAY_STORE_JSON_KEY "$jsonKey" --protected

# Doğrulama
glab variable list
```

---

### Yöntem B: GitLab Web Arayüzünden (Görsel Yol) 🖥️

#### Adım 1: Variables Sayfasını Açma

1. GitLab'da projenizi açın: `https://gitlab.com/mehmetanilcomert-group/wealth_calculator`
2. Sol menüden **Settings** (⚙️ Ayarlar) tıklayın
3. **CI/CD** alt menüsüne girin
4. Sayfada aşağı kaydırarak **Variables** bölümünü bulun
5. **Expand** butonuna tıklayarak bölümü açın

#### Adım 2: ANDROID_KEYSTORE_BASE64 Değişkeni Ekleme

1. **Add variable** butonuna tıklayın
2. Açılan formda:
   - **Key:** `ANDROID_KEYSTORE_BASE64`
   - **Value:** Aşağıdaki PowerShell komutunun çıktısını yapıştırın:
     ```powershell
     [Convert]::ToBase64String([IO.File]::ReadAllBytes("c:\repos\wealth_calculator\wealth_calculator\android\wealth-calculator-key.jks"))
     ```
     Bu komutu çalıştırıp çıkan uzun metni kopyalayın.
   - **Type:** Variable (varsayılan)
   - **Environment scope:** All (varsayılan)
   - **Flags:**
     - ☑️ **Protect variable** → İŞARETLEYİN
     - ☑️ **Mask variable** → İŞARETLEYİN
     - ☐ Expand variable reference → İşaretlemeyin
3. **Add variable** butonuna basın

#### Adım 3: ANDROID_KEY_PROPERTIES Değişkeni Ekleme

1. Tekrar **Add variable** tıklayın
2. Formda:
   - **Key:** `ANDROID_KEY_PROPERTIES`
   - **Value:** Aşağıdaki 4 satırı aynen yapıştırın:
     ```
     storePassword=wealth-calculator-pass-2025
     keyPassword=wealth-calculator-pass-2025
     keyAlias=wealth-calculator
     storeFile=../wealth-calculator-key.jks
     ```
   - **Flags:**
     - ☑️ **Protect variable** → İŞARETLEYİN
     - ☐ Mask variable → İşaretlemeyin (çok satırlı değer mask edilemez)
3. **Add variable** butonuna basın

#### Adım 4: PLAY_STORE_JSON_KEY Değişkeni Ekleme

1. Tekrar **Add variable** tıklayın
2. Formda:
   - **Key:** `PLAY_STORE_JSON_KEY`
   - **Value:** Google Play Console'dan indirdiğiniz JSON dosyasını bir metin editöründe açın, **tüm içeriği** kopyalayıp buraya yapıştırın. Örnek format:
     ```json
     {
       "type": "service_account",
       "project_id": "...",
       "private_key_id": "...",
       "private_key": "-----BEGIN PRIVATE KEY-----\n...",
       "client_email": "gitlab-ci-delivery@....iam.gserviceaccount.com",
       ...
     }
     ```
   - **Flags:**
     - ☑️ **Protect variable** → İŞARETLEYİN
     - ☐ Mask variable → İşaretlemeyin (JSON içeriği mask kurallarına uymaz)
3. **Add variable** butonuna basın

#### Adım 5: Doğrulama

Variables sayfasında 3 değişkenin listelendiğini görmelisiniz:

```
ANDROID_KEYSTORE_BASE64    ••••••    Protected, Masked
ANDROID_KEY_PROPERTIES     ••••••    Protected
PLAY_STORE_JSON_KEY        ••••••    Protected
```

---

## 9. GitLab'a İlk Push ve Dual-Remote

```powershell
# GitLab remote ekle
git remote add gitlab https://gitlab.com/mehmetanilcomert-group/wealth_calculator.git

# İlk push (remote'ta README varsa)
git push gitlab main --force

# Tüm branch'leri gönder (isteğe bağlı)
git push gitlab --all

# Remote kontrolü
git remote -v
# origin   → GitHub
# gitlab   → GitLab
```

---

## 10. Pipeline Tetikleme (Tag ile)

```powershell
# Değişiklikleri commit'le
git add .
git commit -m "feat: GitLab CI/CD + Fastlane pipeline kurulumu"
git push gitlab main

# Tag oluştur ve push et
git tag v1.0.0
git push gitlab v1.0.0
```

GitLab'da **Build → Pipelines** sayfasından takip edin.

---

## Dosya Yapısı

```
wealth_calculator/
├── .gitlab-ci.yml              ← CI/CD pipeline tanımı
├── .gitignore                  ← Güvenlik kuralları
├── CI_CD_REHBER.md             ← Bu dosya
├── scripts/
│   ├── fastlane_find.ps1       ← Fastlane PATH bulucu
│   └── setup_gitlab_variables.ps1 ← GitLab Variables otomatik kurulum
└── android/
    ├── Gemfile                 ← Ruby bağımlılık yönetimi
    ├── Gemfile.lock            ← Versiyon kilidi
    ├── key.properties          ← (gitignore'da, CI/CD üretir)
    ├── wealth-calculator-key.jks ← (gitignore'da, CI/CD üretir)
    └── fastlane/
        ├── Appfile             ← Paket tanımı
        └── Fastfile            ← Deploy lane tanımı
```

---

## Sorun Giderme

| Sorun | Çözüm |
|---|---|
| `fastlane: command not found` | `$env:Path += ";C:\tools\ruby34\bin"` |
| `multi_json is not part of the bundle` | `gem install multi_json` + Gemfile'a ekle |
| `locale UTF-8 warning` | `LC_ALL` ve `LANG` ortam değişkenlerini ayarla |
| `git push rejected (fetch first)` | `git push gitlab main --force` (ilk push için) |
| Pipeline tetiklenmiyor | `.gitlab-ci.yml` dosyasını kontrol et, `only: - tags` olmalı |
| Runner bağlanmıyor | `gitlab-runner status` ve tag eşleşmesini kontrol et |
