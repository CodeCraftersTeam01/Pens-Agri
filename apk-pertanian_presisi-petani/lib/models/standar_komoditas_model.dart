class StandarKomoditasModel {
  final int? id;
  final int? petaniId;
  final int? penyuluhId;
  final int? desaId;
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
  final String? namaPenyuluh;
  final String? namaPetani;
  final String? kecamatan;
  final String? desa;
  final bool isOfficialPreset;

  const StandarKomoditasModel({
    this.id,
    this.petaniId,
    this.penyuluhId,
    this.desaId,
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
    this.status = 'pending',
    this.catatanPenyuluh,
    this.namaPenyuluh,
    this.namaPetani,
    this.kecamatan,
    this.desa,
    this.isOfficialPreset = false,
  });

  bool get isVerified => status.toLowerCase() == 'verified';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory StandarKomoditasModel.fromJson(Map<String, dynamic> json) {
    return StandarKomoditasModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      petaniId: json['petani_id'] is int ? json['petani_id'] : int.tryParse(json['petani_id']?.toString() ?? ''),
      penyuluhId: json['penyuluh_id'] is int ? json['penyuluh_id'] : int.tryParse(json['penyuluh_id']?.toString() ?? ''),
      desaId: json['desa_id'] is int ? json['desa_id'] : int.tryParse(json['desa_id']?.toString() ?? ''),
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
      namaPenyuluh: json['nama_penyuluh']?.toString(),
      namaPetani: json['nama_petani']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      desa: json['desa']?.toString(),
      isOfficialPreset: false,
    );
  }

  Map<String, dynamic> toSubmitJson({required int petaniId, required int desaId}) {
    return {
      'petani_id': petaniId,
      'desa_id': desaId,
      'komoditas': komoditas,
      'varietas': varietas,
      'min_ph': minPh,
      'max_ph': maxPh,
      'min_moisture': minMoisture,
      'max_moisture': maxMoisture,
      'min_n': minN,
      'max_n': maxN,
      'min_p': minP,
      'max_p': maxP,
      'min_k': minK,
      'max_k': maxK,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'min_ec': minEc,
      'max_ec': maxEc,
      'min_fertility': minFertility,
      'max_fertility': maxFertility,
    };
  }

  /// Official Agronomic Presets for Sumenep Commodities
  static List<StandarKomoditasModel> get officialPresets => [
    const StandarKomoditasModel(
      id: -1,
      komoditas: 'Padi',
      varietas: 'Inpari 32 (Standar Resmi)',
      minPh: 5.5,
      maxPh: 6.8,
      minMoisture: 60.0,
      maxMoisture: 85.0,
      minN: 110,
      maxN: 160,
      minP: 30,
      maxP: 50,
      minK: 160,
      maxK: 240,
      minTemp: 24.0,
      maxTemp: 32.0,
      minEc: 1100,
      maxEc: 2100,
      minFertility: 60,
      maxFertility: 100,
      status: 'verified',
      isOfficialPreset: true,
      catatanPenyuluh: 'Standar baku Kementerian Pertanian & Balitsere',
    ),
    const StandarKomoditasModel(
      id: -2,
      komoditas: 'Jagung',
      varietas: 'Bisi 18 / Pioneer (Madura)',
      minPh: 5.8,
      maxPh: 7.2,
      minMoisture: 45.0,
      maxMoisture: 70.0,
      minN: 120,
      maxN: 180,
      minP: 35,
      maxP: 55,
      minK: 150,
      maxK: 230,
      minTemp: 22.0,
      maxTemp: 34.0,
      minEc: 1000,
      maxEc: 1900,
      minFertility: 55,
      maxFertility: 95,
      status: 'verified',
      isOfficialPreset: true,
      catatanPenyuluh: 'Optimal untuk lahan tegalan dan tadah hujan Sumenep',
    ),
    const StandarKomoditasModel(
      id: -3,
      komoditas: 'Cabai Rawit',
      varietas: 'Ori 212 / Madura Super',
      minPh: 6.0,
      maxPh: 7.0,
      minMoisture: 50.0,
      maxMoisture: 75.0,
      minN: 130,
      maxN: 200,
      minP: 40,
      maxP: 65,
      minK: 180,
      maxK: 260,
      minTemp: 23.0,
      maxTemp: 33.0,
      minEc: 1200,
      maxEc: 2200,
      minFertility: 65,
      maxFertility: 100,
      status: 'verified',
      isOfficialPreset: true,
      catatanPenyuluh: 'Sensitif kelembaban tinggi dan anomali pH',
    ),
    const StandarKomoditasModel(
      id: -4,
      komoditas: 'Bawang Merah',
      varietas: 'Rubaru / Bauji',
      minPh: 6.2,
      maxPh: 7.0,
      minMoisture: 40.0,
      maxMoisture: 65.0,
      minN: 100,
      maxN: 150,
      minP: 30,
      maxP: 50,
      minK: 170,
      maxK: 250,
      minTemp: 25.0,
      maxTemp: 35.0,
      minEc: 1100,
      maxEc: 2000,
      minFertility: 60,
      maxFertility: 95,
      status: 'verified',
      isOfficialPreset: true,
      catatanPenyuluh: 'Varietas lokal unggulan Kecamatan Rubaru Sumenep',
    ),
    const StandarKomoditasModel(
      id: -5,
      komoditas: 'Tembakau',
      varietas: 'Madura Prancak-95',
      minPh: 5.5,
      maxPh: 6.5,
      minMoisture: 35.0,
      maxMoisture: 60.0,
      minN: 80,
      maxN: 130,
      minP: 25,
      maxP: 45,
      minK: 180,
      maxK: 280,
      minTemp: 26.0,
      maxTemp: 36.0,
      minEc: 900,
      maxEc: 1800,
      minFertility: 50,
      maxFertility: 90,
      status: 'verified',
      isOfficialPreset: true,
      catatanPenyuluh: 'Komoditas andalan musim kemarau Kabupaten Sumenep',
    ),
  ];
}
