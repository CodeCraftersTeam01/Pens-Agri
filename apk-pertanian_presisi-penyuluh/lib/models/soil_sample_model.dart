/// Represents the real-time 8-in-1 Modbus soil telemetry readings.
class SoilTelemetry {
  final double temp;
  final double moisture;
  final int conductivity;
  final double ph;
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final int fertility;
  final DateTime timestamp;

  const SoilTelemetry({
    this.temp = 0.0,
    this.moisture = 0.0,
    this.conductivity = 0,
    this.ph = 0.0,
    this.nitrogen = 0,
    this.phosphorus = 0,
    this.potassium = 0,
    this.fertility = 0,
    required this.timestamp,
  });

  factory SoilTelemetry.empty() {
    return SoilTelemetry(timestamp: DateTime.now());
  }

  bool get isValid =>
      temp > 0 || moisture > 0 || conductivity > 0 || ph > 0 || nitrogen > 0;
}

/// Comprehensive Soil Sample Model matching the API specification payload contract.
class SoilSampleModel {
  final double latitude;
  final double longitude;
  final String namaDesa;
  final String komoditas;
  final String varietas;
  final double hasilPanenLalu;
  final String satuanPanen; // 'ton' or 'sak'

  // 8 Soil Telemetry readings
  final double temp;
  final double moisture;
  final int conductivity;
  final double ph;
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final int fertility;

  // 3 Required Photo File paths
  final String? fotoDaunPath;
  final String? fotoPohonPath;
  final String? fotoTanahPath;

  const SoilSampleModel({
    required this.latitude,
    required this.longitude,
    required this.namaDesa,
    required this.komoditas,
    required this.varietas,
    required this.hasilPanenLalu,
    required this.satuanPanen,
    required this.temp,
    required this.moisture,
    required this.conductivity,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.fertility,
    this.fotoDaunPath,
    this.fotoPohonPath,
    this.fotoTanahPath,
  });

  Map<String, String> toFormFieldMap() {
    return {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'nama_desa': namaDesa,
      'komoditas': komoditas,
      'varietas': varietas,
      'hasil_panen_lalu': hasilPanenLalu.toString(),
      'satuan_panen': satuanPanen,
      'temp': temp.toStringAsFixed(1),
      'moisture': moisture.toStringAsFixed(1),
      'conductivity': conductivity.toString(),
      'ph': ph.toStringAsFixed(1),
      'nitrogen': nitrogen.toString(),
      'phosphorus': phosphorus.toString(),
      'potassium': potassium.toString(),
      'fertility': fertility.toString(),
    };
  }
}
