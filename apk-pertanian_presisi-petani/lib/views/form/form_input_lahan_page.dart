import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/colors.dart';
import '../../core/services/location_service.dart';

class FormInputLahanPage extends StatefulWidget {
  final Map<String, dynamic> sensorData;
  const FormInputLahanPage({super.key, required this.sensorData});

  @override
  State<FormInputLahanPage> createState() => _FormInputLahanPageState();
}

class _FormInputLahanPageState extends State<FormInputLahanPage> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  bool _isGettingGPS = false;

  // Controllers Input Form
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _desaController = TextEditingController();
  final TextEditingController _sumberAirCtrl = TextEditingController();
  final TextEditingController _kondisiAirCtrl = TextEditingController();
  final TextEditingController _sumberEnergiCtrl = TextEditingController();
  final TextEditingController _pembajakCtrl = TextEditingController();
  final TextEditingController _komoditasCtrl = TextEditingController();
  final TextEditingController _luasLahanCtrl = TextEditingController();
  final TextEditingController _statusLahanCtrl = TextEditingController();

  // Pilihan Radio (ya / tidak)
  String _irigasi = "ya";
  String _listrik = "ya";
  String _pompaAir = "ya";
  String _tadahanHujan = "tidak";
  String _kelompokTani = "ya";
  String _gagalPanen = "tidak";

  @override
  void initState() {
    super.initState();
    _getActualGPSLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _desaController.dispose();
    _sumberAirCtrl.dispose();
    _kondisiAirCtrl.dispose();
    _sumberEnergiCtrl.dispose();
    _pembajakCtrl.dispose();
    _komoditasCtrl.dispose();
    _luasLahanCtrl.dispose();
    _statusLahanCtrl.dispose();
    super.dispose();
  }

  Future<void> _getActualGPSLocation() async {
    setState(() => _isGettingGPS = true);
    final result = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _isGettingGPS = false;
        if (result.isSuccess) {
          _latController.text = result.latitude.toString();
          _lonController.text = result.longitude.toString();
        } else {
          _showSnackBar(
            result.errorMessage ?? "Gagal mengambil koordinat GPS.",
            AppColors.tertiaryAmber,
          );
        }
      });
    }
  }

  Future<void> _simpanDataKeAPI() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    const String apiUrl = "https://pertanian.pmapowers.com/api/soil/save";

    // Exact JSON payload preserving original backend contract
    final Map<String, dynamic> bodyData = {
      "latitude": double.tryParse(_latController.text) ?? 0.0,
      "longitude": double.tryParse(_lonController.text) ?? 0.0,
      "nama_desa": _desaController.text.trim(),
      "irigasi": _irigasi,
      "listrik": _listrik,
      "pompa_air": _pompaAir,
      "sumber_air": _sumberAirCtrl.text.trim(),
      "kondisi_air": _kondisiAirCtrl.text.trim(),
      "sumber_energi_pompa": _sumberEnergiCtrl.text.trim(),
      "pembajak": _pembajakCtrl.text.trim(),
      "tadahan_hujan": _tadahanHujan,
      "komoditas": _komoditasCtrl.text.trim(),
      "luas_lahan": _luasLahanCtrl.text.trim(),
      "status_lahan": _statusLahanCtrl.text.trim(),
      "kelompok_tani": _kelompokTani,
      "gagal_panen": _gagalPanen,
      // 8 sensor telemetry readings
      "temp": widget.sensorData['temp'],
      "moisture": widget.sensorData['moisture'],
      "conductivity": widget.sensorData['conductivity'],
      "ph": widget.sensorData['ph'],
      "nitrogen": widget.sensorData['nitrogen'],
      "phosphorus": widget.sensorData['phosphorus'],
      "potassium": widget.sensorData['potassium'],
      "fertility": widget.sensorData['fertility'],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      final responseJson = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && responseJson['status'] == true) {
        _showSnackBar(
          "Sukses: ${responseJson['message'] ?? 'Data tersimpan ke server cloud'}",
          AppColors.primary,
        );
        Navigator.pop(context);
      } else {
        _showSnackBar(
          "Gagal: ${responseJson['message'] ?? 'Respons Error Server'}",
          AppColors.errorAlert,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Koneksi gagal ke server cloud: $e", AppColors.errorAlert);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        title: Text(
          "Form Kuesioner Lahan",
          style: AppTypography.headlineSm.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 12),
                  Text("Menyimpan data ke server cloud..."),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Sensor Summary Chip
                  _buildSensorSummaryCard(),
                  const SizedBox(height: 14),

                  // Section 1: Koordinat & Wilayah
                  _buildSectionCard(
                    title: "KOORDINAT & WILAYAH",
                    icon: Icons.pin_drop,
                    trailing: _isGettingGPS
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.my_location,
                                color: AppColors.primary, size: 20),
                            tooltip: "Ambil Ulang GPS",
                            onPressed: _getActualGPSLocation,
                          ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latController,
                              label: "Latitude (Otomatis GPS)",
                              isNumber: true,
                              icon: Icons.explore_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _lonController,
                              label: "Longitude (Otomatis GPS)",
                              isNumber: true,
                              icon: Icons.explore_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _desaController,
                        label: "Nama Desa / Kelurahan",
                        icon: Icons.location_city,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Section 2: Informasi Profil Tani
                  _buildSectionCard(
                    title: "INFORMASI PROFIL TANI",
                    icon: Icons.agriculture,
                    children: [
                      _buildTextField(
                        controller: _komoditasCtrl,
                        label: "Komoditas Utama (Misal: Jagung / Padi)",
                        icon: Icons.grass,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _luasLahanCtrl,
                        label: "Luas Lahan (Misal: 0.5 Hektar)",
                        icon: Icons.square_foot,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _statusLahanCtrl,
                        label: "Status Lahan (Misal: Milik Sendiri / Sewa)",
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _pembajakCtrl,
                        label: "Alat Pembajak (Misal: Traktor / Sapi / Manual)",
                        icon: Icons.precision_manufacturing_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildRadioChoice(
                        title: "Apakah ada Irigasi?",
                        groupValue: _irigasi,
                        onChanged: (val) => setState(() => _irigasi = val!),
                      ),
                      const Divider(height: 16),
                      _buildRadioChoice(
                        title: "Apakah mengandalkan Tadah Hujan?",
                        groupValue: _tadahanHujan,
                        onChanged: (val) => setState(() => _tadahanHujan = val!),
                      ),
                      const Divider(height: 16),
                      _buildRadioChoice(
                        title: "Apakah Tergabung Kelompok Tani?",
                        groupValue: _kelompokTani,
                        onChanged: (val) => setState(() => _kelompokTani = val!),
                      ),
                      const Divider(height: 16),
                      _buildRadioChoice(
                        title: "Pernah Gagal Panen Terakhir?",
                        groupValue: _gagalPanen,
                        onChanged: (val) => setState(() => _gagalPanen = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Section 3: Infrastruktur Air & Energi
                  _buildSectionCard(
                    title: "INFRASTRUKTUR AIR & ENERGI",
                    icon: Icons.bolt,
                    children: [
                      _buildRadioChoice(
                        title: "Apakah Ada Listrik?",
                        groupValue: _listrik,
                        onChanged: (val) => setState(() => _listrik = val!),
                      ),
                      const Divider(height: 16),
                      _buildRadioChoice(
                        title: "Apakah Ada Pompa Air?",
                        groupValue: _pompaAir,
                        onChanged: (val) => setState(() => _pompaAir = val!),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _sumberAirCtrl,
                        label: "Sumber Air Utama (Misal: Sumur Bor / Sungai)",
                        icon: Icons.water,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _kondisiAirCtrl,
                        label: "Kondisi Ketersediaan Air (Misal: Tersedia / Lancar)",
                        icon: Icons.opacity,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _sumberEnergiCtrl,
                        label: "Sumber Energi Pompa (Misal: BBM / PLN / Surya)",
                        icon: Icons.solar_power_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _simpanDataKeAPI,
                      icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 22),
                      label: Text(
                        "SIMPAN KE SERVER CLOUD",
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 15,
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSensorSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "8 Data Sensor Probe Terpasang",
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            "pH: ${widget.sensorData['ph']} | N: ${widget.sensorData['nitrogen']}",
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: AppTypography.bodyMd,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.outline)
            : null,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? "$label wajib diisi" : null,
    );
  }

  Widget _buildRadioChoice({
    required String title,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildChoiceChip(
              label: "Ya",
              isSelected: groupValue == "ya",
              onTap: () => onChanged("ya"),
            ),
            const SizedBox(width: 10),
            _buildChoiceChip(
              label: "Tidak",
              isSelected: groupValue == "tidak",
              onTap: () => onChanged("tidak"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
