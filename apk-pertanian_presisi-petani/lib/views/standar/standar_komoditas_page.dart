import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_session_service.dart';
import '../../models/standar_komoditas_model.dart';
import '../../models/wilayah_model.dart';
import '../widgets/sumenep_location_picker_dialog.dart';

class StandarKomoditasPage extends StatefulWidget {
  const StandarKomoditasPage({super.key});

  @override
  State<StandarKomoditasPage> createState() => _StandarKomoditasPageState();
}

class _StandarKomoditasPageState extends State<StandarKomoditasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<StandarKomoditasModel> _officialPresets = StandarKomoditasModel.officialPresets;
  List<StandarKomoditasModel> _myStandards = [];
  bool _isLoadingMyStandards = false;
  UserSession? _userSession;

  // Selected default village for submission (Default: Gapura Barat)
  DesaModel _currentDesa = const DesaModel(id: 79, kecamatan: 'Gapura', desa: 'Gapura Barat');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyStandards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyStandards() async {
    setState(() => _isLoadingMyStandards = true);
    final session = await UserSessionService.getSession();
    _userSession = session;
    _currentDesa = DesaModel(
      id: session.selectedDesaId,
      kecamatan: session.selectedKecamatan,
      desa: session.selectedDesaName,
    );
    final list = await ApiService.getMyStandards(session.userId);
    if (mounted) {
      setState(() {
        _myStandards = list;
        _isLoadingMyStandards = false;
      });
    }
  }

  void _openSubmitStandardDialog() {
    final formKey = GlobalKey<FormState>();
    final komoditasCtrl = TextEditingController();
    final varietasCtrl = TextEditingController();
    final minPhCtrl = TextEditingController(text: '6.0');
    final maxPhCtrl = TextEditingController(text: '7.0');
    final minMoistCtrl = TextEditingController(text: '50');
    final maxMoistCtrl = TextEditingController(text: '80');
    final minNCtrl = TextEditingController(text: '100');
    final maxNCtrl = TextEditingController(text: '150');
    final minPCtrl = TextEditingController(text: '25');
    final maxPCtrl = TextEditingController(text: '45');
    final minKCtrl = TextEditingController(text: '150');
    final maxKCtrl = TextEditingController(text: '220');
    final minTempCtrl = TextEditingController(text: '20.0');
    final maxTempCtrl = TextEditingController(text: '35.0');
    final minEcCtrl = TextEditingController(text: '1000');
    final maxEcCtrl = TextEditingController(text: '2000');
    final minFertCtrl = TextEditingController(text: '50');
    final maxFertCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_task, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajukan Standar Mandiri',
                                style: AppTypography.headlineSm.copyWith(fontSize: 18),
                              ),
                              Text(
                                'Akan diverifikasi oleh Penyuluh Desa ${_currentDesa.desa}',
                                style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Village info bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lokasi: ${_currentDesa.desa}, Kec. ${_currentDesa.kecamatan}',
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              SumenepLocationPickerDialog.show(
                                context,
                                initialDesa: _currentDesa.desa,
                                onSelected: (desa, penyuluh) {
                                  setState(() {
                                    _currentDesa = desa;
                                  });
                                  setModalState(() {});
                                },
                              );
                            },
                            child: const Text('Ganti'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Commodity & Variety
                    TextFormField(
                      controller: komoditasCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Komoditas (contoh: Padi, Jagung, Cabai)',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Komoditas wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: varietasCtrl,
                      decoration: InputDecoration(
                        labelText: 'Varietas (contoh: Ciherang / Madura Super)',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Varietas wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Ambang Batas 8 Parameter Sensor Tanah:',
                      style: AppTypography.headlineSm.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 12),

                    _buildDualNumberRow('pH Tanah', minPhCtrl, maxPhCtrl, 'Min pH', 'Max pH'),
                    _buildDualNumberRow('Kelembaban (%)', minMoistCtrl, maxMoistCtrl, 'Min %', 'Max %'),
                    _buildDualNumberRow('Nitrogen (N) [mg/kg]', minNCtrl, maxNCtrl, 'Min N', 'Max N'),
                    _buildDualNumberRow('Fosfor (P) [mg/kg]', minPCtrl, maxPCtrl, 'Min P', 'Max P'),
                    _buildDualNumberRow('Kalium (K) [mg/kg]', minKCtrl, maxKCtrl, 'Min K', 'Max K'),
                    _buildDualNumberRow('Suhu Tanah (°C)', minTempCtrl, maxTempCtrl, 'Min °C', 'Max °C'),
                    _buildDualNumberRow('EC Listrik (us/cm)', minEcCtrl, maxEcCtrl, 'Min EC', 'Max EC'),
                    _buildDualNumberRow('Fertility / Salinitas', minFertCtrl, maxFertCtrl, 'Min', 'Max'),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mengirim pengajuan standar komoditas...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );

                          final result = await ApiService.submitStandarPetani(
                            petaniId: _userSession?.userId ?? 1,
                            desaId: _currentDesa.id,
                            komoditas: komoditasCtrl.text.trim(),
                            varietas: varietasCtrl.text.trim(),
                            minPh: double.tryParse(minPhCtrl.text) ?? 6.0,
                            maxPh: double.tryParse(maxPhCtrl.text) ?? 7.0,
                            minMoisture: double.tryParse(minMoistCtrl.text) ?? 50.0,
                            maxMoisture: double.tryParse(maxMoistCtrl.text) ?? 80.0,
                            minN: int.tryParse(minNCtrl.text) ?? 100,
                            maxN: int.tryParse(maxNCtrl.text) ?? 150,
                            minP: int.tryParse(minPCtrl.text) ?? 25,
                            maxP: int.tryParse(maxPCtrl.text) ?? 45,
                            minK: int.tryParse(minKCtrl.text) ?? 150,
                            maxK: int.tryParse(maxKCtrl.text) ?? 220,
                            minTemp: double.tryParse(minTempCtrl.text) ?? 20.0,
                            maxTemp: double.tryParse(maxTempCtrl.text) ?? 35.0,
                            minEc: int.tryParse(minEcCtrl.text) ?? 1000,
                            maxEc: int.tryParse(maxEcCtrl.text) ?? 2000,
                            minFertility: int.tryParse(minFertCtrl.text) ?? 50,
                            maxFertility: int.tryParse(maxFertCtrl.text) ?? 100,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']?.toString() ?? ''),
                                backgroundColor: result['success'] == true
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            );
                            _loadMyStandards();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Kirim Pengajuan ke Penyuluh',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDualNumberRow(
    String label,
    TextEditingController minCtrl,
    TextEditingController maxCtrl,
    String minHint,
    String maxHint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: minCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: minHint,
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: maxCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: maxHint,
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Standar Komoditas',
          style: AppTypography.headlineSm.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.verified), text: 'Rekomendasi Resmi'),
            Tab(icon: Icon(Icons.edit_document), text: 'Standar Mandiri'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitStandardDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Standar'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Official Server Recommendations
          _buildOfficialPresetsTab(),

          // Tab 2: My Custom Standards & Verification Status
          _buildMyStandardsTab(),
        ],
      ),
    );
  }

  Widget _buildOfficialPresetsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _officialPresets.length,
      itemBuilder: (ctx, i) {
        final item = _officialPresets[i];
        return _buildStandardCard(item);
      },
    );
  }

  Widget _buildMyStandardsTab() {
    if (_isLoadingMyStandards) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_myStandards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.post_add, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Standar Mandiri',
                style: AppTypography.headlineSm.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda dapat mengajukan ambang batas komoditas khusus untuk dievaluasi oleh Penyuluh Pertanian desa Anda.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openSubmitStandardDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajukan Standar Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyStandards,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        itemCount: _myStandards.length,
        itemBuilder: (ctx, i) {
          final item = _myStandards[i];
          return _buildStandardCard(item);
        },
      ),
    );
  }

  Widget _buildStandardCard(StandarKomoditasModel item) {
    Color statusBg = AppColors.statusOptimalBg;
    Color statusText = AppColors.statusOptimalText;
    String statusLabel = 'Terverifikasi Resmi';
    IconData statusIcon = Icons.check_circle;

    if (item.isPending) {
      statusBg = AppColors.statusDeficitBg;
      statusText = AppColors.statusDeficitText;
      statusLabel = 'Menunggu Verifikasi Penyuluh';
      statusIcon = Icons.hourglass_top;
    } else if (item.isRejected) {
      statusBg = AppColors.statusExcessBg;
      statusText = AppColors.statusExcessText;
      statusLabel = 'Ditolak Penyuluh';
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isOfficialPreset
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: item.isOfficialPreset
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.komoditas,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        item.varietas,
                        style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusText, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 8 Parameter Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildParamPill('pH', '${item.minPh} - ${item.maxPh}'),
                    _buildParamPill('Lembab', '${item.minMoisture.toInt()}-${item.maxMoisture.toInt()}%'),
                    _buildParamPill('N', '${item.minN}-${item.maxN} mg'),
                    _buildParamPill('P', '${item.minP}-${item.maxP} mg'),
                    _buildParamPill('K', '${item.minK}-${item.maxK} mg'),
                    _buildParamPill('Suhu', '${item.minTemp}-${item.maxTemp}°C'),
                    _buildParamPill('EC', '${item.minEc}-${item.maxEc} us'),
                    _buildParamPill('Fertility', '${item.minFertility}-${item.maxFertility}'),
                  ],
                ),

                // Notes if available
                if (item.catatanPenyuluh != null && item.catatanPenyuluh!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.speaker_notes, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Catatan: ${item.catatanPenyuluh}',
                            style: AppTypography.bodySm.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.onSurface, fontSize: 11),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
