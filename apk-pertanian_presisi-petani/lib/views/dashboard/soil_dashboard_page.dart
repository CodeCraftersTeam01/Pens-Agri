import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/usb_serial_service.dart';
import '../form/form_input_lahan_page.dart';

class SoilDashboardPage extends StatefulWidget {
  const SoilDashboardPage({super.key});

  @override
  State<SoilDashboardPage> createState() => _SoilDashboardPageState();
}

class _SoilDashboardPageState extends State<SoilDashboardPage> {
  final UsbSerialService _usbService = UsbSerialService();
  bool _isQuerying = false;
  bool _showTerminalLogs = false;

  Future<void> _toggleConnect() async {
    if (_usbService.isConnected) {
      await _usbService.disconnect();
    } else {
      await _usbService.connect();
    }
  }

  Future<void> _readSensor() async {
    setState(() => _isQuerying = true);
    final telemetry = await _usbService.readSensorData();
    if (mounted) {
      setState(() => _isQuerying = false);
      if (telemetry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membaca sensor probe. Cek kabel USB & Modbus.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToForm(SoilTelemetry telemetry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormInputLahanPage(
          sensorData: telemetry.toMap(),
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
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.sensors, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'AgriSensor Petani',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PENS',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'NPK 8-in-1 Soil Monitor',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
              ],
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
            // 1. USB Connection Status Banner
            _buildUsbStatusBar(),

            // 2. Main 8-in-1 Telemetry Grid
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _buildSensorGrid(),
                  if (_showTerminalLogs) ...[
                    const SizedBox(height: 14),
                    _buildTerminalLogCard(),
                  ],
                ],
              ),
            ),

            // 3. Bottom Action Controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsbStatusBar() {
    return ValueListenableBuilder<UsbStatus>(
      valueListenable: _usbService.statusNotifier,
      builder: (context, status, _) {
        final isConnected = status == UsbStatus.connected;
        final isConnecting = status == UsbStatus.connecting;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isConnected
                ? AppColors.statusOptimalBg
                : AppColors.surfaceContainerHigh,
            border: Border(
              bottom: BorderSide(
                color: isConnected
                    ? AppColors.statusOptimalBorder
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.primary : AppColors.errorAlert,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _usbService.statusMessageNotifier,
                    builder: (context, msg, _) => SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Text(
                        msg,
                        style: AppTypography.bodySm.copyWith(
                          color: isConnected
                              ? AppColors.statusOptimalText
                              : AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isConnecting ? null : _toggleConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? AppColors.errorAlert : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isConnected ? 'PUTUS' : (isConnecting ? 'KONEK...' : 'KONEK'),
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorGrid() {
    return ValueListenableBuilder<SoilTelemetry>(
      valueListenable: _usbService.telemetryNotifier,
      builder: (context, telemetry, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildParamCard(
              title: "Kelembapan Tanah",
              value: "${telemetry.moisture.toStringAsFixed(1)} %",
              icon: Icons.water_drop,
              accentColor: const Color(0xFF0284C7),
            ),
            _buildParamCard(
              title: "Suhu Tanah",
              value: "${telemetry.temp.toStringAsFixed(1)} °C",
              icon: Icons.thermostat,
              accentColor: const Color(0xFFEA580C),
            ),
            _buildParamCard(
              title: "Konduktivitas (EC)",
              value: "${telemetry.conductivity} µS/cm",
              icon: Icons.bolt,
              accentColor: const Color(0xFF9333EA),
            ),
            _buildParamCard(
              title: "Kadar Asam (pH)",
              value: telemetry.ph.toStringAsFixed(1),
              icon: Icons.science,
              accentColor: AppColors.primaryLight,
            ),
            _buildParamCard(
              title: "Nitrogen (N)",
              value: "${telemetry.nitrogen} mg/kg",
              icon: Icons.grass,
              accentColor: const Color(0xFF16A34A),
            ),
            _buildParamCard(
              title: "Fosfor (P)",
              value: "${telemetry.phosphorus} mg/kg",
              icon: Icons.grain,
              accentColor: const Color(0xFFDC2626),
            ),
            _buildParamCard(
              title: "Kalium (K)",
              value: "${telemetry.potassium} mg/kg",
              icon: Icons.eco,
              accentColor: const Color(0xFF0891B2),
            ),
            _buildParamCard(
              title: "Kesuburan (Fertility)",
              value: "${telemetry.fertility} mg/kg",
              icon: Icons.compost,
              accentColor: const Color(0xFFD97706),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParamCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: AppTypography.labelMetric.copyWith(
                color: accentColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
              logs.isEmpty ? "Terminal monitor siap..." : logs,
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

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ValueListenableBuilder<UsbStatus>(
        valueListenable: _usbService.statusNotifier,
        builder: (context, status, _) {
          final isConnected = status == UsbStatus.connected;

          return ValueListenableBuilder<SoilTelemetry>(
            valueListenable: _usbService.telemetryNotifier,
            builder: (context, telemetry, _) {
              final hasReadSensor = telemetry.isValid;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Baca Data Sensor
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: isConnected && !_isQuerying ? _readSensor : null,
                      icon: _isQuerying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bolt, color: Colors.white, size: 20),
                      label: Text(
                        _isQuerying
                            ? "MEMBACA MODBUS..."
                            : "BACA DATA SENSOR",
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Lanjut Isi Data Lahan (Hanya muncul jika sudah pernah baca data sensor)
                  if (hasReadSensor) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToForm(telemetry),
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        label: Text(
                          "LANJUT ISI DATA LAHAN",
                          style: AppTypography.labelMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
