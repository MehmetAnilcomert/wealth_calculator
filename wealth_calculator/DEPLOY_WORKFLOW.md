# 🚀 GitLab & GitHub Çift Yönlü Git İş Akışı (Workflow)

Bu proje güvenliği ve açık kaynak yapısını korumak amacıyla iki farklı Git remote (GitHub ve GitLab) ile iki farklı branch (`main` ve `gitlab-deploy`) kullanmaktadır.

## 🌟 Neden İki Branch Var?
- **GitHub'da** projenin açık kaynak kodları bulunuyor. CI/CD şifrelerinin veya Fastlane dosyalarının burada olmasını **istemiyoruz.**
- **GitLab'da** ise gizli (private) CI/CD ortamımız var. Otomatik Play Store dağıtımı burada yapılıyor.

Bu yüzden kodlamayı `main`'de yapıp, sadece yayınlayacağımız zaman `gitlab-deploy` branch'ini kullanacağız.

---

## 🛠️ Adım 1: Günlük Geliştirme (Sadece `main`)

Tüm kod geliştirme süreçlerinizi her zaman **`main`** branch'inde yapın.

```powershell
# Eğer main branch'inde değilseniz geçin:
git checkout main

# Kodlarınızı yazın, test edin...
git add .
git commit -m "feat: yeni ozellik eklendi"

# GitHub'a gönderin (VS Code Sync butonunu kullanabilirsiniz)
git push origin main
```
*Bu aşamada GitLab ile hiçbir işiniz yok, dosyalarınız tamamen public repo için güvenlidir.*

---

## 🚀 Adım 2: Play Store'a Yeni Sürüm Gönderme (Sadece `gitlab-deploy`)

Uygulamanın yeni bir sürümünü Play Store'a göndermek (veya AAB test build'i almak) istediğinizde şu adımları **sırasıyla** izleyin:

### 2.1 - CI/CD Branch'ine Geçiş
```powershell
git checkout gitlab-deploy
```

### 2.2 - Yeni Kodları Çekme (Merge)
Main'de yazdığınız yeni özellikleri deploy branch'ine dahil edin:
```powershell
git merge main
```

### 2.3 - Sürüm Etiketi (Tag) Oluşturma
GitLab pipeline'ı **sadece** tag atıldığında tetiklenir (Örn: v1.0.0, v1.0.1 vb.):
```powershell
git tag v1.0.0
```

### 2.4 - GitLab'a Gönderme (Deploy Başlatma)
Branch güncellemelerini ve attığınız tag'i sadece **gitlab** remote'una yollayın:
```powershell
# Önce güncel branch'i yollayın
git push gitlab gitlab-deploy

# Sonra pipeline'ı tetikleyecek tag'i yollayın
git push gitlab v1.0.0
```

🎉 **Tebrikler!** GitLab'da `Build -> Pipelines` sayfasını açtığınızda pipeline'ın başladığını göreceksiniz.

### 2.5 - Geri Dönüş
Deploy işlemi bittikten (veya başladıktan) hemen sonra, yeni kodlar yazmaya devam etmek için güvenli limanınız olan `main` branch'ine dönmeyi unutmayın:
```powershell
git checkout main
```

---

## 💡 Hızlı Özet Kopya Kağıdı
```powershell
git checkout gitlab-deploy
git merge main
git tag v1.0.1
git push gitlab gitlab-deploy
git push gitlab v1.0.1
git checkout main
```
