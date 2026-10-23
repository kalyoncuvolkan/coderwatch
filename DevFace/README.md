# DevFace — Apple Watch Ultra için terminal temalı saat ekranı

Yazılımcılar için animasyonlu, terminal görünümlü bir "saat kadranı":

```
➜ ~ git:(main) date +%R▌
14:07:42
let today = "23 Eki Cum"
epoch: 1792741627
day [█████░░░░░] 58%
bat: 87%  // W43
```

- Her dakika prompt'a yeni bir komut yazılır (`now`, `date +%R`, `uptime`, `git log -1` …)
- Dakika değişince değişen rakamlar kısa bir "decrypt" efektiyle yerine oturur
- Arka planda hafif bir kod yağmuru (`Canvas` + `TimelineView`, durumsuz)
- **Digital Crown** → tema değiştirir: `terminal`, `ultra` (International Orange), `dracula`, `night` (Ultra Night Mode'a uygun kırmızı)
- **Ekrana dokun** → kod yağmurunu aç/kapat
- **Always-On** → animasyonlar durur, dakikada bir güncellenen sade görünüm
- **Komplikasyonlar** (WidgetKit): Modular Ultra gibi sistem kadranlarına eklenir, günün ilerlemesini gösterir, dokununca DevFace açılır

## Önemli kısıt

Apple, watchOS'ta üçüncü parti saat kadranı yapılmasına izin vermiyor. DevFace bu yüzden
**kadran gibi davranan bir watchOS uygulaması + sistem kadranları için komplikasyonlar** olarak yazıldı.

## Kurulum (Mac gerekmez): GitHub Actions → TestFlight

Derleme GitHub'ın macOS makinelerinde yapılır, fastlane imzalayıp TestFlight'a yükler.
Sertifika ve profiller App Store Connect API ile oluşturulur ve bu deponun
`match-certificates` dalında `MATCH_PASSWORD` ile şifreli olarak saklanır.

### 1. App Store Connect API anahtarı

[App Store Connect](https://appstoreconnect.apple.com) → **Kullanıcılar ve Erişim → Entegrasyonlar → App Store Connect API → Ekip Anahtarları** → **+**

- Ad: `GitHub Actions`, Erişim: **Admin** (sertifika ve profil oluşturabilmesi için)
- `.p8` dosyasını indir. **Yalnızca bir kez indirilebilir.**
- Sayfadaki **Issuer ID** ve anahtarın **Key ID** değerini not et.

**Team ID**: [developer.apple.com/account](https://developer.apple.com/account) → Membership details.

### 2. GitHub secret'ları

Depo → **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Değer |
|---|---|
| `ASC_KEY_ID` | Key ID (ör. `ABC123DEFG`) |
| `ASC_ISSUER_ID` | Issuer ID (UUID) |
| `ASC_KEY_P8` | `.p8` dosyasının tüm içeriği, `-----BEGIN PRIVATE KEY-----` satırları dahil |
| `TEAM_ID` | 10 karakterlik Team ID |
| `MATCH_PASSWORD` | Kendi belirlediğin güçlü bir parola (sertifikaları şifreler, kaybetme) |

### 3. İlk kurulum: `setup`

**Actions → "DevFace → TestFlight" iş akışı → Run workflow → lane: `setup`**

Bundle ID'leri (`com.vkalyoncu.devface.watchkitapp`, `.watch` ve `.watch.widgets`) kaydeder, dağıtım
sertifikasını ve App Store profillerini oluşturur. Yalnızca bir kez çalıştırman yeterli.

### 4. App Store Connect'te uygulama kaydı

**Uygulamalar → + → Yeni Uygulama**

- Platform: **iOS** (yalnızca saatte çalışan uygulamalar da iOS altında açılır)
- Ad: App Store genelinde benzersiz olmalı, ör. `DevFace Terminal`. Uygulamayı yayınlamayacaksan önemi yok.
- Bundle ID: `com.vkalyoncu.devface.watchkitapp`
- SKU: `devface`

### 5. Her yeni sürüm: `beta`

**Run workflow → lane: `beta`**. Derleme yaklaşık 10–15 dakika sürer. Ardından Apple'ın build'i
işlemesi 10–30 dakika daha alabilir.

### 6. Saate yükleme

1. App Store Connect → uygulama → **TestFlight → Dahili Test** grubuna kendini ekle.
2. iPhone'da **TestFlight** uygulamasını aç ve DevFace'i yükle. Saat uygulaması saate otomatik yükler.
   Yüklemezse iPhone'daki Watch uygulamasında **Mevcut Uygulamalar** bölümünden yükle.

TestFlight build'leri 90 gün geçerli. Süre dolmadan `beta`'yı yeniden çalıştırman yeterli.

> Bundle ID'yi değiştirmek istersen `project.yml` ve `fastlane/Fastfile` içindeki `com.vkalyoncu.devface` kısmını güncelle.

### Mac'in olursa

```bash
brew install xcodegen
cd DevFace && xcodegen generate && open DevFace.xcodeproj
```

Signing & Capabilities'te Team'ini seç ve doğrudan saate çalıştır.

## Saatte "kadran" gibi kullanmak

- **Ayarlar → Genel → Saate Dön → 1 saat sonra**: DevFace açıkken bileğini indirip kaldırdığında uygulama ekranda kalır.
- **Action Button**: Ayarlar → Action Button → Kestirme → "Uygulamayı Aç: DevFace". Turuncu tuşa tek basışla döner.
- **Komplikasyon**: Modular Ultra kadranında bir alanı düzenleyip DevFace'i seç; dokununca uygulama açılır.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `DevFace/FaceView.swift` | Ana ekran: TimelineView, Digital Crown, dokunma, Always-On |
| `DevFace/TerminalClock.swift` | Terminal satırları, yazma ve decrypt animasyonları |
| `DevFace/CodeRainView.swift` | Arka plandaki kod yağmuru |
| `DevFace/Theme.swift` | Temalar ve deterministik `noise()` yardımcı fonksiyonu |
| `DevFaceWidgets/DevFaceWidgets.swift` | Circular / corner / inline / rectangular komplikasyonlar |
| `preview/index.html` | Tarayıcıda açılan canlı önizleme (aynı animasyon mantığı) |
| `photos-face/` | Mac'siz alternatif: Fotoğraflar kadranı için 8 görsel |
| `fastlane/Fastfile` | `setup` ve `beta` lane'leri (imzalama ve TestFlight) |
| `../.github/workflows/devface-testflight.yml` | GitHub Actions iş akışı |

## Pil

Animasyon sadece ekran tam parlaklıktayken çalışır (20 fps); Always-On'da dakikada bir güncellenir.
Pil ömrü seni rahatsız ederse ekrana dokunup kod yağmurunu kapatabilirsin.
