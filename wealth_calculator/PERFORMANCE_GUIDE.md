## 🚀 Flutter Performance İyileştirme Rehberi

### Frame Dropping Nedir?
- Flutter 60 FPS hedefler → Her frame **16.6ms**'de tamamlanmalı
- Ana thread'de **16.6ms**'den uzun süren işler frame dropping'e neden olur
- "Skipped X frames" = Kullanıcı jank/takılma görür

---

## 📊 Performans Sorunlarını Tespit Etme

### 1. **Flutter DevTools Kullanımı**
```bash
# Android Studio'da
Run → Flutter DevTools → Performance

# VS Code'da
Ctrl+Shift+P → "Dart: Open DevTools"
```

**Performance View'da kontrol edilecekler:**
- Timeline: Hangi widget'lar uzun sürüyor
- Rebuild count: Gereksiz rebuild'ler
- Build time: Her widget'ın build süresi

### 2. **Performance Overlay**
```dart
MaterialApp(
  showPerformanceOverlay: true, // Ekranda FPS gösterir
)
```

### 3. **Profiling**
```bash
flutter run --profile  # Release mode benzeri ama profiling aktif
```

---

## 🔧 Yaygın Performans Sorunları ve Çözümleri

### ❌ Problem 1: Build Metodunda Ağır İşler
```dart
// YANLIŞ
Widget build(BuildContext context) {
  final data = expensiveCalculation(); // Her build'de çalışır
  return Text(data);
}

// DOĞRU
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late String data;
  
  @override
  void initState() {
    super.initState();
    data = expensiveCalculation(); // Sadece bir kez
  }
  
  @override
  Widget build(BuildContext context) => Text(data);
}
```

### ❌ Problem 2: Her Build'de Yeni Controller
```dart
// YANLIŞ - Memory leak + Performance sorunu
Widget build(BuildContext context) {
  return TextField(
    controller: TextEditingController(text: value), // Her build'de yeni
  );
}

// DOĞRU
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
```

### ❌ Problem 3: Lottie/Animation Optimizasyonu
```dart
// YANLIŞ
Widget build(BuildContext context) {
  return Lottie.asset('animation.json'); // Her build'de parse
}

// DOĞRU
Widget build(BuildContext context) {
  return RepaintBoundary( // Animasyonu izole et
    child: Lottie.asset(
      'animation.json',
      repeat: false,
      frameRate: FrameRate.max, // FPS limitle
    ),
  );
}

// EN İYİSİ - Lazy load
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final Future<LottieComposition> _composition;
  
  @override
  void initState() {
    super.initState();
    _composition = AssetLottie('animation.json').load();
  }
  
  @override
  Widget build(BuildContext context) {
    return Lottie(composition: _composition);
  }
}
```

### ❌ Problem 4: Liste Performansı
```dart
// YANLIŞ
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// DOĞRU
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// EN İYİSİ - Daha uzun listeler için
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
  separatorBuilder: (context, index) => const Divider(),
)
```

### ❌ Problem 5: Image Loading
```dart
// YANLIŞ
Image.network('url') // Her seferinde yükler

// DOĞRU
CachedNetworkImage(
  imageUrl: 'url',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### ❌ Problem 6: Gereksiz Rebuilder
```dart
// YANLIŞ
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    return Column(
      children: [
        ExpensiveWidget(), // State değişmese bile rebuild
        Text(state.value),
      ],
    );
  },
)

// DOĞRU
Column(
  children: [
    const ExpensiveWidget(), // const = rebuild olmaz
    BlocBuilder<MyBloc, MyState>(
      builder: (context, state) => Text(state.value),
    ),
  ],
)
```

---

## 🎯 Sizin Projeniz İçin Özel Çözümler

### 1. Application Initialize Optimization
```dart
// lib/product/init/application_initialize.dart

static Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Paralel çalıştır
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    NotificationService.init(),
    DbHelper.instance.database,
  ]);
  
  // Non-critical işleri ertele
  Future.microtask(() {
    tz.initializeTimeZones();
  });
}
```

### 2. BLoC State Management Best Practices
```dart
// Doğru buildWhen kullanımı
BlocBuilder<InvoiceFormBloc, InvoiceFormState>(
  buildWhen: (previous, current) {
    // Sadece gerekli değişikliklerde rebuild
    return previous.amount != current.amount;
  },
  builder: (context, state) => AmountField(amount: state.amount),
)
```

### 3. Profile View Optimization
```dart
// Statistics Card'ı cache'le
class _StatisticsCardState extends State<StatisticsCard> {
  late final List<StatItem> _cachedStats;
  
  @override
  void initState() {
    super.initState();
    _cachedStats = _buildStatItems(widget.stats);
  }
  
  @override
  void didUpdateWidget(StatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats) {
      _cachedStats = _buildStatItems(widget.stats);
    }
  }
}
```

---

## 🛠️ Debugging Araçları

### 1. **Performance Profiling**
```bash
flutter run --profile
# DevTools'da Timeline'ı incele
```

### 2. **Widget Inspector**
```bash
# Widget tree'yi görselleştir
# Hangi widget'lar yeniden build oluyor gör
```

### 3. **Memory Profiler**
```bash
# Memory leak'leri tespit et
# Dispose edilmeyen controller'ları bul
```

### 4. **Custom Performance Monitoring**
```dart
import 'dart:developer' as developer;

void measurePerformance() {
  final stopwatch = Stopwatch()..start();
  
  expensiveOperation();
  
  stopwatch.stop();
  developer.log('Operation took: ${stopwatch.elapsedMilliseconds}ms');
  
  if (stopwatch.elapsedMilliseconds > 16) {
    developer.log('⚠️ WARNING: This might cause frame drops!');
  }
}
```

---

## ✅ Checklist: Frame Dropping Çözümü

- [ ] **DevTools Performance** ile profile yap
- [ ] **Build metodu** 16ms altında mı?
- [ ] **Controller'lar** doğru dispose ediliyor mu?
- [ ] **Lottie/Image** cache'leniyor mu?
- [ ] **ListView** builder kullanıyor mu?
- [ ] **const** constructor'lar var mı?
- [ ] **RepaintBoundary** animasyonlarda kullanılıyor mu?
- [ ] **Ağır işler** isolate'de mi?
- [ ] **BLoC buildWhen** optimize edilmiş mi?
- [ ] **Initialization** paralel mi?

---

## 🎓 Best Practices

1. **const Kullan**: Mümkün olduğunca const widget kullan
2. **Lazy Load**: Veriler sadece gerektiğinde yüklensin
3. **Cache**: Tekrar tekrar hesaplanan değerleri cache'le
4. **Isolate**: CPU-intensive işleri main thread'den ayır
5. **Profiling**: Düzenli olarak profile et
6. **Testing**: Performance testleri ekle

---

## 📚 Kaynaklar

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [DevTools Performance View](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
