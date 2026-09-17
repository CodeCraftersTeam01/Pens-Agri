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
