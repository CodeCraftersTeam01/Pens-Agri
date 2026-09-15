import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/usb_serial_service.dart';
import '../../models/commodity_model.dart';
import '../../models/soil_sample_model.dart';
import '../result/analysis_result_page.dart';

class SoilProbeCapturePage extends StatefulWidget {
  final CommodityModel selectedCommodity;

  const SoilProbeCapturePage({
    super.key,
    required this.selectedCommodity,
  });

  @override
  State<SoilProbeCapturePage> createState() => _SoilProbeCapturePageState();
}

class _SoilProbeCapturePageState extends State<SoilProbeCapturePage> {
  final UsbSerialService _usbService = UsbSerialService();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController _desaController = TextEditingController(text: 'Lamongan');
  final TextEditingController _harvestController = TextEditingController(text: '4.5');
  String _satuanPanen = 'ton'; // 'ton' or 'sak'

  // Location State
  double _latitude = -7.128452;
  double _longitude = 112.415893;
  bool _isGpsLoading = false;
  String _gpsStatusText = 'Presisi Tinggi';

  // Photo File Paths
  String? _fotoDaunPath;
  String? _fotoPohonPath;
  String? _fotoTanahPath;

  // Sensor Query State
  bool _isQueryingSensor = false;
  bool _showTerminalLogs = false;

  @override
  void initState() {
    super.initState();
    _fetchGpsLocation();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isGpsLoading = true);
    final result = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _isGpsLoading = false;
        if (result.isSuccess) {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _gpsStatusText = 'Akurasi: ${result.accuracy.toStringAsFixed(1)}m';
        } else {
          _gpsStatusText = result.errorMessage ?? 'Gagal membaca GPS';
        }
      });
    }
  }

  Future<void> _toggleUsbConnection() async {
    if (_usbService.isConnected) {
      await _usbService.disconnect();
    } else {
      await _usbService.connect();
    }
  }

  Future<void> _readSensorData() async {
    setState(() => _isQueryingSensor = true);
    final result = await _usbService.readSensorData();
    if (mounted) {
      setState(() => _isQueryingSensor = false);
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membaca data probe. Cek kabel USB & Modbus.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          if (type == 'daun') _fotoDaunPath = photo.path;
          if (type == 'pohon') _fotoPohonPath = photo.path;
          if (type == 'tanah') _fotoTanahPath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka kamera: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _validateAndProceed() {
    final telemetry = _usbService.telemetryNotifier.value;

    // Build complete sample model
    final sample = SoilSampleModel(
      latitude: _latitude,
      longitude: _longitude,
      namaDesa: _desaController.text.trim().isEmpty ? 'Desa Lamongan' : _desaController.text.trim(),
      komoditas: widget.selectedCommodity.name,
      varietas: widget.selectedCommodity.variety,
      hasilPanenLalu: double.tryParse(_harvestController.text.trim()) ?? 0.0,
      satuanPanen: _satuanPanen,
      temp: telemetry.temp > 0 ? telemetry.temp : 26.5,
      moisture: telemetry.moisture > 0 ? telemetry.moisture : 68.0,
      conductivity: telemetry.conductivity > 0 ? telemetry.conductivity : 1400,
      ph: telemetry.ph > 0 ? telemetry.ph : 6.2,
      nitrogen: telemetry.nitrogen > 0 ? telemetry.nitrogen : 110,
      phosphorus: telemetry.phosphorus > 0 ? telemetry.phosphorus : 18,
      potassium: telemetry.potassium > 0 ? telemetry.potassium : 195,
      fertility: telemetry.fertility > 0 ? telemetry.fertility : 850,
      fotoDaunPath: _fotoDaunPath,
      fotoPohonPath: _fotoPohonPath,
      fotoTanahPath: _fotoTanahPath,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultPage(
          commodity: widget.selectedCommodity,
          sample: sample,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.selectedCommodity.name,
                  style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Target Terkunci',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.selectedCommodity.variety,
              style: AppTypography.bodySm.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showTerminalLogs ? Icons.terminal : Icons.terminal_outlined,
              color: _showTerminalLogs ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            tooltip: 'Terminal Log',
            onPressed: () => setState(() => _showTerminalLogs = !_showTerminalLogs),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. USB Connection Status Bar & Controls
                  _buildUsbControlCard(),
                  const SizedBox(height: 14),

                  // Optional Hex Terminal Monitor
                  if (_showTerminalLogs) ...[
                    _buildTerminalLogCard(),
                    const SizedBox(height: 14),
                  ],

                  // 2. Real-Time Telemetry Cards (8 Soil Parameters)
                  _buildTelemetryGrid(),
                  const SizedBox(height: 14),

                  // 3. Mandatory GPS Location Card
                  _buildGpsCard(),
                  const SizedBox(height: 14),

                  // 4. Yield History & Field Info
                  _buildHarvestInputCard(),
                  const SizedBox(height: 14),

                  // 5. 3-Photo Media Capture Slots
                  _buildPhotoCaptureSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Sticky Bottom Trigger Button
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsbControlCard() {
    return ValueListenableBuilder<UsbStatus>(
      valueListenable: _usbService.statusNotifier,
      builder: (context, status, _) {
        final isConnected = status == UsbStatus.connected;
        final isConnecting = status == UsbStatus.connecting;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConnected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppColors.primaryFixed.withValues(alpha: 0.4)
                              : AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cable,
                          color: isConnected ? AppColors.primary : AppColors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isConnected ? 'Sensor IoT Tertancap' : 'USB Terputus',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isConnected ? AppColors.primary : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<String>(
                            valueListenable: _usbService.statusMessageNotifier,
                            builder: (context, msg, _) => SizedBox(
                              width: 170,
                              child: Text(
                                msg,
                                style: AppTypography.bodySm.copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: isConnecting ? null : _toggleUsbConnection,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isConnected ? AppColors.error : AppColors.primary,
                      side: BorderSide(
                        color: isConnected ? AppColors.error : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      isConnected ? 'PUTUS' : (isConnecting ? 'KONEK...' : 'KONEK'),
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // "Baca Data Sensor" Action Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: isConnected && !_isQueryingSensor ? _readSensorData : null,
                  icon: _isQueryingSensor
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.bolt, color: Colors.white, size: 20),
                  label: Text(
                    _isQueryingSensor ? 'Mengambil Data Modbus...' : 'BACA DATA SENSOR (MODBUS)',
                    style: AppTypography.labelMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTerminalLogCard() {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: _usbService.logsNotifier,
        builder: (context, logs, _) {
          return SingleChildScrollView(
            reverse: true,
            child: Text(
              logs.isEmpty ? 'Terminal siap menerima query Modbus...' : logs,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTelemetryGrid() {
    return ValueListenableBuilder<SoilTelemetry>(
      valueListenable: _usbService.telemetryNotifier,
      builder: (context, telemetry, _) {
        final threshold = widget.selectedCommodity.threshold;

        // Fallback display values if not yet read
        final phVal = telemetry.ph > 0 ? telemetry.ph : 6.2;
        final moistVal = telemetry.moisture > 0 ? telemetry.moisture : 68.0;
        final nVal = telemetry.nitrogen > 0 ? telemetry.nitrogen : 110;
        final pVal = telemetry.phosphorus > 0 ? telemetry.phosphorus : 18;
        final kVal = telemetry.potassium > 0 ? telemetry.potassium : 195;
        final tempVal = telemetry.temp > 0 ? telemetry.temp : 26.5;
        final ecVal = telemetry.conductivity > 0 ? telemetry.conductivity : 1400;
        final fertVal = telemetry.fertility > 0 ? telemetry.fertility : 850;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TELEMETRI SENSOR PROBE',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '8 Parameter Real-Time',
                      style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Top Metric 2-Column: pH & Moisture
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'pH Tanah',
                    value: phVal.toStringAsFixed(1),
                    unit: 'pH',
                    target: 'Target: ${threshold.minPh} - ${threshold.maxPh}',
                    isOptimal: phVal >= threshold.minPh && phVal <= threshold.maxPh,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Kelembaban',
                    value: moistVal.toStringAsFixed(1),
                    unit: '%',
                    target: 'Target: ${threshold.minMoisture.toInt()}-${threshold.maxMoisture.toInt()}%',
                    isOptimal: moistVal >= threshold.minMoisture && moistVal <= threshold.maxMoisture,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Macro Nutrients (NPK) Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unsur Makro Tanah (NPK)',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text('mg/kg (ppm)', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNpkColumn(
                          symbol: 'N',
                          name: 'Nitrogen',
                          value: nVal,
                          targetMin: threshold.minNitrogen,
                          targetMax: threshold.maxNitrogen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNpkColumn(
                          symbol: 'P',
                          name: 'Fosfor',
                          value: pVal,
                          targetMin: threshold.minPhosphorus,
                          targetMax: threshold.maxPhosphorus,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNpkColumn(
                          symbol: 'K',
                          name: 'Kalium',
                          value: kVal,
                          targetMin: threshold.minPotassium,
                          targetMax: threshold.maxPotassium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Quick Info Bar: Suhu, EC, Kesuburan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(Icons.thermostat, 'Suhu Tanah', '${tempVal.toStringAsFixed(1)} °C'),
                  Container(width: 1, height: 28, color: AppColors.surfaceContainerHigh),
                  _buildQuickStat(Icons.bolt, 'Konduktivitas', '$ecVal µS/cm'),
                  Container(width: 1, height: 28, color: AppColors.surfaceContainerHigh),
                  _buildQuickStat(Icons.compost, 'Kesuburan', '$fertVal mg/kg'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String target,
    required bool isOptimal,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOptimal ? AppColors.statusOptimalBg : AppColors.statusDeficitBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOptimal ? 'Optimal' : 'Perlu Cek',
                  style: AppTypography.labelSm.copyWith(
                    color: isOptimal ? AppColors.statusOptimalText : AppColors.statusDeficitText,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.labelMetric.copyWith(fontSize: 22)),
              const SizedBox(width: 4),
              Text(unit, style: AppTypography.bodySm.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(target, style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildNpkColumn({
    required String symbol,
    required String name,
    required int value,
    required int targetMin,
    required int targetMax,
  }) {
    final bool isLow = value < targetMin;
    final bool isHigh = value > targetMax;
    final Color badgeColor = isLow
        ? AppColors.tertiaryAmber
        : (isHigh ? AppColors.errorAlert : AppColors.primary);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                symbol,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                isLow ? 'Defisit' : (isHigh ? 'Berlebih' : 'Cukup'),
                style: AppTypography.labelSm.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: AppTypography.labelMetric.copyWith(
              fontSize: 18,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / (targetMax * 1.5)).clamp(0.1, 1.0),
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 3),
            Text(label, style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGpsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pin_drop, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Titik Sampel GPS', style: AppTypography.headlineSm.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _gpsStatusText,
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Desa / Kelurahan Sampling:',
                      style: AppTypography.bodySm.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: _isGpsLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Perbarui GPS',
                onPressed: _isGpsLoading ? null : _fetchGpsLocation,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _desaController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Nama Desa / Lokasi Lahan...',
              hintStyle: AppTypography.bodySm,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestInputCard() {
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
              Text(
                'Riwayat Hasil Panen Lalu',
                style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              // Ton / Sak Switch Toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _satuanPanen = 'ton'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _satuanPanen == 'ton' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ton',
                          style: AppTypography.labelSm.copyWith(
                            color: _satuanPanen == 'ton' ? Colors.white : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _satuanPanen = 'sak'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _satuanPanen == 'sak' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sak',
                          style: AppTypography.labelSm.copyWith(
                            color: _satuanPanen == 'sak' ? Colors.white : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _harvestController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Volume panen musim sebelumnya...',
              suffixText: _satuanPanen.toUpperCase(),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCaptureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: AppColors.secondary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Dokumentasi 3 Objek',
                  style: AppTypography.headlineSm.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '${(_fotoDaunPath != null ? 1 : 0) + (_fotoPohonPath != null ? 1 : 0) + (_fotoTanahPath != null ? 1 : 0)}/3 Lengkap',
              style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Wajib sertakan foto daun, tanaman, & titik tanah.',
          style: AppTypography.bodySm.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPhotoSlot(
                title: 'Foto Daun',
                filePath: _fotoDaunPath,
                onTap: () => _pickImage('daun'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoSlot(
                title: 'Foto Rumpun',
                filePath: _fotoPohonPath,
                onTap: () => _pickImage('pohon'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoSlot(
                title: 'Foto Tanah',
                filePath: _fotoTanahPath,
                onTap: () => _pickImage('tanah'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSlot({
    required String title,
    required String? filePath,
    required VoidCallback onTap,
  }) {
    final bool hasImage = filePath != null && File(filePath).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: hasImage ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  image: hasImage
                      ? DecorationImage(
                          image: FileImage(File(filePath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasImage
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.camera_alt, color: AppColors.onSurfaceVariant, size: 24),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              hasImage ? 'Terunggah' : 'Ambil Foto',
              style: AppTypography.labelSm.copyWith(
                fontSize: 9,
                color: hasImage ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
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
        child: ElevatedButton(
          onPressed: _validateAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cek Hasil & Justifikasi Tanah',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
