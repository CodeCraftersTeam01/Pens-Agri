class NutrientThreshold {
  final double minPh;
  final double maxPh;
  final double minMoisture;
  final double maxMoisture;
  final int minConductivity;
  final int maxConductivity;
  final int minNitrogen;
  final int maxNitrogen;
  final int minPhosphorus;
  final int maxPhosphorus;
  final int minPotassium;
  final int maxPotassium;

  const NutrientThreshold({
    required this.minPh,
    required this.maxPh,
    required this.minMoisture,
    required this.maxMoisture,
    required this.minConductivity,
    required this.maxConductivity,
    required this.minNitrogen,
    required this.maxNitrogen,
    required this.minPhosphorus,
    required this.maxPhosphorus,
    required this.minPotassium,
    required this.maxPotassium,
  });
}

class CommodityModel {
  final String id;
  final String name;
  final String variety;
  final String iconCode;
  final bool isRecommended;
  final int sampleCount;
  final String status;
  final NutrientThreshold threshold;

  const CommodityModel({
    required this.id,
    required this.name,
    required this.variety,
    required this.iconCode,
    this.isRecommended = false,
    this.sampleCount = 0,
    this.status = 'Siap',
    required this.threshold,
  });

  static List<CommodityModel> get defaultCommodities => [
    const CommodityModel(
      id: 'padi',
      name: 'Padi',
      variety: 'Inpari 32 / Ciherang',
      iconCode: 'grass',
      isRecommended: true,
      sampleCount: 42,
      status: 'Aktif',
      threshold: NutrientThreshold(
        minPh: 6.0,
        maxPh: 6.8,
        minMoisture: 60.0,
        maxMoisture: 80.0,
        minConductivity: 1000,
        maxConductivity: 2000,
        minNitrogen: 100,
        maxNitrogen: 150,
        minPhosphorus: 25,
        maxPhosphorus: 40,
        minPotassium: 150,
        maxPotassium: 220,
      ),
    ),
    const CommodityModel(
      id: 'cabai',
      name: 'Cabai Rawit',
      variety: 'Varietas Ori 212',
      iconCode: 'local_fire_department',
      sampleCount: 18,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 5.8,
        maxPh: 6.8,
        minMoisture: 50.0,
        maxMoisture: 70.0,
        minConductivity: 1200,
        maxConductivity: 2200,
        minNitrogen: 120,
        maxNitrogen: 180,
        minPhosphorus: 30,
        maxPhosphorus: 50,
        minPotassium: 160,
        maxPotassium: 240,
      ),
    ),
    const CommodityModel(
      id: 'jagung',
      name: 'Jagung',
      variety: 'Bisi 18 / Hibrida',
      iconCode: 'agriculture',
      sampleCount: 25,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 5.6,
        maxPh: 7.2,
        minMoisture: 55.0,
        maxMoisture: 75.0,
        minConductivity: 1100,
        maxConductivity: 2100,
        minNitrogen: 130,
        maxNitrogen: 190,
        minPhosphorus: 25,
        maxPhosphorus: 45,
        minPotassium: 140,
        maxPotassium: 210,
      ),
    ),
    const CommodityModel(
      id: 'singkong',
      name: 'Singkong',
      variety: 'Varietas Manggu',
      iconCode: 'spa',
      sampleCount: 12,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 5.5,
        maxPh: 7.0,
        minMoisture: 45.0,
        maxMoisture: 65.0,
        minConductivity: 800,
        maxConductivity: 1800,
        minNitrogen: 80,
        maxNitrogen: 140,
        minPhosphorus: 20,
        maxPhosphorus: 35,
        minPotassium: 130,
        maxPotassium: 200,
      ),
    ),
    const CommodityModel(
      id: 'tomat',
      name: 'Tomat',
      variety: 'Varietas Servo F1',
      iconCode: 'nutrition',
      sampleCount: 15,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 6.0,
        maxPh: 6.8,
        minMoisture: 60.0,
        maxMoisture: 80.0,
        minConductivity: 1400,
        maxConductivity: 2500,
        minNitrogen: 110,
        maxNitrogen: 170,
        minPhosphorus: 30,
        maxPhosphorus: 55,
        minPotassium: 180,
        maxPotassium: 260,
      ),
    ),
    const CommodityModel(
      id: 'bawang',
      name: 'Bawang Merah',
      variety: 'Varietas Brebes',
      iconCode: 'nature',
      sampleCount: 30,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 5.8,
        maxPh: 6.8,
        minMoisture: 55.0,
        maxMoisture: 70.0,
        minConductivity: 1000,
        maxConductivity: 2000,
        minNitrogen: 90,
        maxNitrogen: 150,
        minPhosphorus: 25,
        maxPhosphorus: 45,
        minPotassium: 150,
        maxPotassium: 220,
      ),
    ),
    const CommodityModel(
      id: 'kacang',
      name: 'Kacang Tanah',
      variety: 'Varietas Tuban',
      iconCode: 'compost',
      sampleCount: 9,
      status: 'Siap',
      threshold: NutrientThreshold(
        minPh: 6.0,
        maxPh: 6.5,
        minMoisture: 50.0,
        maxMoisture: 70.0,
        minConductivity: 900,
        maxConductivity: 1900,
        minNitrogen: 70,
        maxNitrogen: 120,
        minPhosphorus: 20,
        maxPhosphorus: 40,
        minPotassium: 120,
        maxPotassium: 190,
      ),
    ),
    const CommodityModel(
      id: 'lainnya',
      name: 'Komoditas Lainnya',
      variety: 'Kustom Mandiri',
      iconCode: 'add_circle',
      sampleCount: 0,
      status: 'Kustom',
      threshold: NutrientThreshold(
        minPh: 6.0,
        maxPh: 7.0,
        minMoisture: 50.0,
        maxMoisture: 80.0,
        minConductivity: 1000,
        maxConductivity: 2000,
        minNitrogen: 100,
        maxNitrogen: 150,
        minPhosphorus: 25,
        maxPhosphorus: 45,
        minPotassium: 150,
        maxPotassium: 220,
      ),
    ),
  ];
}
