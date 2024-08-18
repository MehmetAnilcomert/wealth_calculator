enum OnemSeviyesi { yuksek, orta, dusuk }

class Invoice {
  int? id;
  DateTime tarih;
  double tutar;
  String aciklama;
  OnemSeviyesi onemSeviyesi;
  bool odendiMi;

  Invoice({
    this.id,
    required this.tarih,
    required this.tutar,
    required this.aciklama,
    this.onemSeviyesi = OnemSeviyesi.orta,
    this.odendiMi = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarih': tarih.toIso8601String(),
      'tutar': tutar,
      'aciklama': aciklama,
      'onemSeviyesi': onemSeviyesi.toString().split('.').last, // Enum ismini al
      'odendiMi': odendiMi ? 1 : 0,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      tarih: DateTime.parse(map['tarih']),
      tutar: map['tutar'],
      aciklama: map['aciklama'],
      onemSeviyesi: OnemSeviyesi.values.firstWhere(
        (e) => e.toString().split('.').last == map['onemSeviyesi'],
        orElse: () => OnemSeviyesi.orta, // Varsayılan değer
      ),
      odendiMi: map['odendiMi'] == 1,
    );
  }
}
