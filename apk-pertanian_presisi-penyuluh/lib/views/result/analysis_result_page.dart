import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/commodity_model.dart';
import '../../models/soil_sample_model.dart';

enum NutrientStatus { optimal, deficit, excess }

class AnalysisResultPage extends StatefulWidget {
  final CommodityModel commodity;
  final SoilSampleModel sample;

  const AnalysisResultPage({
    super.key,
    required this.commodity,
    required this.sample,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  String _selectedMapFilter = 'all';

  NutrientStatus _evaluateStatus(num value, num min, num max) {
    if (value < min) return NutrientStatus.deficit;
    if (value > max) return NutrientStatus.excess;
    return NutrientStatus.optimal;
  }

  Future<void> _uploadDataToCloud() async {
    setState(() => _isUploading = true);
    final response = await _apiService.saveSoilSample(widget.sample);
    if (!mounted) return;
    setState(() => _isUploading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              response.isSuccess ? Icons.check_circle : Icons.error,
              color: response.isSuccess ? AppColors.primary : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              response.isSuccess ? 'Sinkronisasi Berhasil' : 'Sinkronisasi Gagal',
              style: AppTypography.headlineSm.copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          response.message,
          style: AppTypography.bodyMd,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (response.isSuccess) {
                // Navigate back to home
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threshold = widget.commodity.threshold;
    final sample = widget.sample;

    final phStatus = _evaluateStatus(sample.ph, threshold.minPh, threshold.maxPh);
    final nStatus = _evaluateStatus(sample.nitrogen, threshold.minNitrogen, threshold.maxNitrogen);
    final pStatus = _evaluateStatus(sample.phosphorus, threshold.minPhosphorus, threshold.maxPhosphorus);
    final kStatus = _evaluateStatus(sample.potassium, threshold.minPotassium, threshold.maxPotassium);
    final moistStatus = _evaluateStatus(sample.moisture, threshold.minMoisture, threshold.maxMoisture);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hasil Justifikasi & Rekomendasi',
          style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Overview Lab & Commodity Card
                  _buildHeaderOverviewCard(),
                  const SizedBox(height: 14),

                  // 2. Comparative Justification Table (5 Soil Indicators)
                  _buildComparativeSection(
                    phStatus: phStatus,
                    nStatus: nStatus,
                    pStatus: pStatus,
                    kStatus: kStatus,
                    moistStatus: moistStatus,
                  ),
                  const SizedBox(height: 14),

                  // 3. Remediation Advisory Cards
                  _buildRemediationSection(
                    phStatus: phStatus,
                    nStatus: nStatus,
                    pStatus: pStatus,
                    kStatus: kStatus,
                  ),
                  const SizedBox(height: 14),

                  // 4. Sampling Distribution Map Presentation Card
                  _buildDistributionMapCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Sticky Bottom Trigger Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.biotech, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'HASIL ANALISIS PENS IOT',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Desa ${widget.sample.namaDesa}',
                style: AppTypography.bodySm.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Evaluasi Kesuburan Tanah',
            style: AppTypography.headlineMd.copyWith(fontSize: 18),
          ),
          Text(
            '${widget.commodity.name} (${widget.commodity.variety}) • Panen Lalu: ${widget.sample.hasilPanenLalu} ${widget.sample.satuanPanen.toUpperCase()}',
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),

          // Diagnostic Summary Alert
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS DIAGNOSTIK',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dibutuhkan suplementasi unsur fosfor & pembenahan aerasi tanah.',
                        style: AppTypography.bodySm.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeSection({
    required NutrientStatus phStatus,
    required NutrientStatus nStatus,
    required NutrientStatus pStatus,
    required NutrientStatus kStatus,
    required NutrientStatus moistStatus,
  }) {
    final threshold = widget.commodity.threshold;
    final sample = widget.sample;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.balance, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Justifikasi Unsur Kimiawi',
                  style: AppTypography.headlineSm.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '5 Indikator',
              style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // pH Indicator
        _buildJustificationCard(
          symbol: 'pH',
          title: 'Derajat Keasaman (pH)',
          actualValue: sample.ph.toStringAsFixed(1),
          unit: 'pH',
          refText: '${threshold.minPh} – ${threshold.maxPh}',
          status: phStatus,
          progress: (sample.ph / 14.0).clamp(0.0, 1.0),
        ),
        const SizedBox(height: 8),

        // Nitrogen Indicator
        _buildJustificationCard(
          symbol: 'N',
          title: 'Nitrogen Total',
          actualValue: '${sample.nitrogen}',
          unit: 'ppm',
          refText: '${threshold.minNitrogen} – ${threshold.maxNitrogen} ppm',
          status: nStatus,
          progress: (sample.nitrogen / (threshold.maxNitrogen * 1.4)).clamp(0.0, 1.0),
        ),
        const SizedBox(height: 8),

        // Phosphorus Indicator
        _buildJustificationCard(
          symbol: 'P',
          title: 'Fosfor Tersedia (P₂O₅)',
          actualValue: '${sample.phosphorus}',
          unit: 'ppm',
          refText: '${threshold.minPhosphorus} – ${threshold.maxPhosphorus} ppm',
          status: pStatus,
          progress: (sample.phosphorus / (threshold.maxPhosphorus * 1.4)).clamp(0.0, 1.0),
        ),
        const SizedBox(height: 8),

        // Potassium Indicator
        _buildJustificationCard(
          symbol: 'K',
          title: 'Kalium Tertukar (K₂O)',
          actualValue: '${sample.potassium}',
          unit: 'ppm',
          refText: '${threshold.minPotassium} – ${threshold.maxPotassium} ppm',
          status: kStatus,
          progress: (sample.potassium / (threshold.maxPotassium * 1.4)).clamp(0.0, 1.0),
        ),
        const SizedBox(height: 8),

        // Moisture Indicator
        _buildJustificationCard(
          symbol: 'H₂O',
          title: 'Kadar Air / Kelembaban',
          actualValue: sample.moisture.toStringAsFixed(1),
          unit: '%',
          refText: '${threshold.minMoisture.toInt()} – ${threshold.maxMoisture.toInt()} %',
          status: moistStatus,
          progress: (sample.moisture / 100.0).clamp(0.0, 1.0),
        ),
      ],
    );
  }

  Widget _buildJustificationCard({
    required String symbol,
    required String title,
    required String actualValue,
    required String unit,
    required String refText,
    required NutrientStatus status,
    required double progress,
  }) {
    Color badgeBg;
    Color badgeText;
    Color barColor;
    String statusLabel;

    switch (status) {
      case NutrientStatus.optimal:
        badgeBg = AppColors.statusOptimalBg;
        badgeText = AppColors.statusOptimalText;
        barColor = AppColors.primary;
        statusLabel = 'NORMAL';
        break;
      case NutrientStatus.deficit:
        badgeBg = AppColors.statusDeficitBg;
        badgeText = AppColors.statusDeficitText;
        barColor = AppColors.tertiaryAmber;
        statusLabel = 'DEFISIT / KURANG';
        break;
      case NutrientStatus.excess:
        badgeBg = AppColors.statusExcessBg;
        badgeText = AppColors.statusExcessText;
        barColor = AppColors.errorAlert;
        statusLabel = 'BERLEBIH';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.labelSm.copyWith(
                    color: badgeText,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                children: [
                  Text(
                    actualValue,
                    style: AppTypography.labelMetric.copyWith(
                      fontSize: 18,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(unit, style: AppTypography.bodySm.copyWith(fontSize: 11)),
                  const SizedBox(width: 6),
                  Text('(Aktual)', style: AppTypography.bodySm.copyWith(fontSize: 10, color: AppColors.outline)),
                ],
              ),
              Text(
                'Rujukan: $refText',
                style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemediationSection({
    required NutrientStatus phStatus,
    required NutrientStatus nStatus,
    required NutrientStatus pStatus,
    required NutrientStatus kStatus,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.agriculture, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saran Perbaikan Fisik & Kimiawi',
                    style: AppTypography.headlineSm.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'REKOMENDASI KURATIF TIM TI PENS',
                    style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Remediation Item 1: Soil Aeration
          _buildRemediationItem(
            step: '1',
            title: 'Pengolahan Tanah & Aerasi',
            desc: 'Lakukan pembajakan dangkal (15 cm) dan penambahan jerami terdekomposisi untuk memperbaiki porositas agregat tanah.',
          ),
          const SizedBox(height: 8),

          // Remediation Item 2: Organic Matter
          _buildRemediationItem(
            step: '2',
            title: 'Aplikasi Pupuk Organik / Kompos',
            desc: 'Tambahkan kompos matang 2 ton/ha atau pupuk kandang guna meningkatkan kapasitas tukar kation (KTK) rizosfer.',
          ),
          const SizedBox(height: 8),

          // Remediation Item 3: Specific Chemical Action
          _buildRemediationItem(
            step: '3',
            title: pStatus == NutrientStatus.deficit ? 'Suplementasi Pupuk Fosfat (SP-36)' : 'Keseimbangan Unsur Hara Makro',
            desc: pStatus == NutrientStatus.deficit
                ? 'Aplikasikan SP-36 dosis terukur pada saat pemupukan dasar untuk mengembalikan ketersediaan fosfat mikro.'
                : 'Pertahankan pemupukan berimbang NPK sesuai jadwal fase pertumbuhan tanaman.',
          ),
        ],
      ),
    );
  }

  Widget _buildRemediationItem({
    required String step,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.bodySm.copyWith(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionMapCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_searching, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Peta Sebaran Sampling Wilayah',
                    style: AppTypography.headlineSm.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '14 Titik Aktif',
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMapChip('all', 'Semua Titik (14)'),
                const SizedBox(width: 6),
                _buildMapChip('penyuluh', 'Penyuluh (5)'),
                const SizedBox(width: 6),
                _buildMapChip('poktan', 'Poktan Makmur (6)'),
                const SizedBox(width: 6),
                _buildMapChip('petani', 'Petani Mandiri (3)'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mock Visual Map Container
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 32, color: AppColors.outline),
                      const SizedBox(height: 4),
                      Text(
                        'Koordinat Plot: ${widget.sample.latitude.toStringAsFixed(4)}, ${widget.sample.longitude.toStringAsFixed(4)}',
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Wilayah Binaan BPP Lamongan',
                      style: AppTypography.labelSm.copyWith(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapChip(String id, String label) {
    final isSelected = _selectedMapFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMapFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isUploading ? null : _uploadDataToCloud,
          icon: _isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.cloud_upload, size: 20),
          label: Text(
            _isUploading ? 'Menyinkronkan ke Cloud...' : 'SIMPAN KE RIWAYAT CLOUD',
            style: AppTypography.headlineSm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
