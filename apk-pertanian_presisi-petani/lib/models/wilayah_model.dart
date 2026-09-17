class DesaModel {
  final int id;
  final String kecamatan;
  final String desa;

  const DesaModel({
    required this.id,
    required this.kecamatan,
    required this.desa,
  });

  factory DesaModel.fromJson(Map<String, dynamic> json) {
    return DesaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      kecamatan: json['kecamatan']?.toString() ?? '',
      desa: json['desa']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kecamatan': kecamatan,
      'desa': desa,
    };
  }

  @override
  String toString() => '$desa ($kecamatan)';
}

class PairedPenyuluhModel {
  final int id;
  final String nama;
  final String email;
  final String noHp;
  final String? foto;
  final String kecamatan;
  final String desa;

  const PairedPenyuluhModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    this.foto,
    required this.kecamatan,
    required this.desa,
  });

  factory PairedPenyuluhModel.fromJson(Map<String, dynamic> json) {
    return PairedPenyuluhModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? 'Penyuluh Pertanian',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      foto: json['foto_users']?.toString(),
      kecamatan: json['kecamatan']?.toString() ?? '',
      desa: json['desa']?.toString() ?? '',
    );
  }
}
