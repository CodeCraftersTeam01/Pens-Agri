class StandarKomoditasModel {
  final int id;
  final int petaniId;
  final int? penyuluhId;
  final int desaId;
  final String komoditas;
  final String varietas;
  final double minPh;
  final double maxPh;
  final double minMoisture;
  final double maxMoisture;
  final int minN;
  final int maxN;
  final int minP;
  final int maxP;
  final int minK;
  final int maxK;
  final double minTemp;
  final double maxTemp;
  final int minEc;
  final int maxEc;
  final int minFertility;
  final int maxFertility;
  final String status; // 'pending', 'verified', 'rejected'
  final String? catatanPenyuluh;
  final String? namaPetani;
  final String? emailPetani;
  final String? noHpPetani;
  final String? namaPenyuluh;
  final String? kecamatan;
  final String? desa;

  const StandarKomoditasModel({
    required this.id,
    required this.petaniId,
    this.penyuluhId,
    required this.desaId,
    required this.komoditas,
    required this.varietas,
    required this.minPh,
    required this.maxPh,
    required this.minMoisture,
    required this.maxMoisture,
    required this.minN,
    required this.maxN,
    required this.minP,
    required this.maxP,
    required this.minK,
    required this.maxK,
    required this.minTemp,
    required this.maxTemp,
    required this.minEc,
    required this.maxEc,
    required this.minFertility,
    required this.maxFertility,
    required this.status,
    this.catatanPenyuluh,
    this.namaPetani,
    this.emailPetani,
    this.noHpPetani,
    this.namaPenyuluh,
    this.kecamatan,
    this.desa,
  });

  bool get isVerified => status.toLowerCase() == 'verified';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory StandarKomoditasModel.fromJson(Map<String, dynamic> json) {
    return StandarKomoditasModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      petaniId: json['petani_id'] is int ? json['petani_id'] : int.tryParse(json['petani_id']?.toString() ?? '0') ?? 0,
      penyuluhId: json['penyuluh_id'] is int ? json['penyuluh_id'] : int.tryParse(json['penyuluh_id']?.toString() ?? ''),
      desaId: json['desa_id'] is int ? json['desa_id'] : int.tryParse(json['desa_id']?.toString() ?? '0') ?? 0,
      komoditas: json['komoditas']?.toString() ?? '',
      varietas: json['varietas']?.toString() ?? '',
      minPh: double.tryParse(json['min_ph']?.toString() ?? '6.0') ?? 6.0,
      maxPh: double.tryParse(json['max_ph']?.toString() ?? '7.0') ?? 7.0,
      minMoisture: double.tryParse(json['min_moisture']?.toString() ?? '50.0') ?? 50.0,
      maxMoisture: double.tryParse(json['max_moisture']?.toString() ?? '80.0') ?? 80.0,
      minN: int.tryParse(json['min_n']?.toString() ?? '100') ?? 100,
      maxN: int.tryParse(json['max_n']?.toString() ?? '150') ?? 150,
      minP: int.tryParse(json['min_p']?.toString() ?? '25') ?? 25,
      maxP: int.tryParse(json['max_p']?.toString() ?? '45') ?? 45,
      minK: int.tryParse(json['min_k']?.toString() ?? '150') ?? 150,
      maxK: int.tryParse(json['max_k']?.toString() ?? '220') ?? 220,
      minTemp: double.tryParse(json['min_temp']?.toString() ?? '20.0') ?? 20.0,
      maxTemp: double.tryParse(json['max_temp']?.toString() ?? '35.0') ?? 35.0,
      minEc: int.tryParse(json['min_ec']?.toString() ?? '1000') ?? 1000,
      maxEc: int.tryParse(json['max_ec']?.toString() ?? '2000') ?? 2000,
      minFertility: int.tryParse(json['min_fertility']?.toString() ?? '50') ?? 50,
      maxFertility: int.tryParse(json['max_fertility']?.toString() ?? '100') ?? 100,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      catatanPenyuluh: json['catatan_penyuluh']?.toString(),
      namaPetani: json['nama_petani']?.toString() ?? 'Petani Desa',
      emailPetani: json['email_petani']?.toString(),
      noHpPetani: json['no_hp_petani']?.toString(),
      namaPenyuluh: json['nama_penyuluh']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      desa: json['desa']?.toString(),
    );
  }
}
