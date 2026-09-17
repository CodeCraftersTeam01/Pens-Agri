import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_session_service.dart';
import '../../models/standar_komoditas_model.dart';
import '../../models/wilayah_model.dart';
import '../widgets/sumenep_location_picker_dialog.dart';

class VerificationInboxPage extends StatefulWidget {
  const VerificationInboxPage({super.key});

  @override
  State<VerificationInboxPage> createState() => _VerificationInboxPageState();
}

class _VerificationInboxPageState extends State<VerificationInboxPage> {
  // Designated Village Assignment (Default: Gapura Barat, Sumenep)
  DesaModel _assignedVillage = const DesaModel(
    id: 79,
    kecamatan: 'Gapura',
    desa: 'Gapura Barat',
  );

  List<StandarKomoditasModel> _pendingList = [];
  bool _isLoading = true;
  UserSession? _userSession;

  @override
  void initState() {
    super.initState();
    _initSessionAndLoad();
  }

  Future<void> _initSessionAndLoad() async {
    final session = await UserSessionService.getSession();
    _userSession = session;
    _assignedVillage = DesaModel(
      id: session.selectedDesaId,
      kecamatan: session.selectedKecamatan,
      desa: session.selectedDesaName,
    );
    _loadPendingSubmissions();
  }

  Future<void> _loadPendingSubmissions() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getPendingStandards(desaId: _assignedVillage.id);
    if (mounted) {
      setState(() {
        _pendingList = list;
        _isLoading = false;
      });
    }
  }

  void _changeAssignedVillage() {
    SumenepLocationPickerDialog.show(
      context,
      initialDesa: _assignedVillage.desa,
      onSelected: (desa) {
        setState(() {
          _assignedVillage = desa;
        });
        _loadPendingSubmissions();
      },
    );
  }

  void _showVerificationDialog(StandarKomoditasModel item) {
    final notesCtrl = TextEditingController();
    bool isProcessing = false;

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

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fact_check, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evaluasi Standar Petani',
                              style: AppTypography.headlineSm.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Pengajuan dari ${item.namaPetani ?? "Petani Desa"}',
                              style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Farmer Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: AppColors.outline),
                            const SizedBox(width: 6),
                            Text('Petani: ${item.namaPetani ?? "-"}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: AppColors.outline),
                            const SizedBox(width: 6),
                            Text('No HP: ${item.noHpPetani ?? "-"}', style: AppTypography.bodySm),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: AppColors.outline),
                            const SizedBox(width: 6),
                            Text('Wilayah: ${item.desa ?? _assignedVillage.desa}, Kec. ${item.kecamatan ?? _assignedVillage.kecamatan}', style: AppTypography.bodySm),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Commodity & Variety
                  Text(
                    'Komoditas: ${item.komoditas}',
                    style: AppTypography.headlineSm.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Varietas: ${item.varietas}',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Parameter Sensor yang Diajukan Petani:',
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // 8 Param Comparison Table
                  _buildParamComparisonTable(item),
                  const SizedBox(height: 16),

                  // Notes for farmer
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan / Rekomendasi Penyuluh (Opsional)',
                      hintText: 'Misal: Standar disetujui, harap perhatikan pupuk KCl di musim kemarau...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons: Reject or Verify
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  setModalState(() => isProcessing = true);
                                  final navigator = Navigator.of(ctx);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final res = await ApiService.verifyStandard(
                                    id: item.id,
                                    penyuluhId: _userSession?.userId ?? 2,
                                    status: 'rejected',
                                    catatanPenyuluh: notesCtrl.text.trim(),
                                  );
                                  if (mounted) {
                                    navigator.pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(res['message']?.toString() ?? 'Standar ditolak'),
                                        backgroundColor: AppColors.errorAlert,
                                      ),
                                    );
                                    _loadPendingSubmissions();
                                  }
                                },
                          icon: const Icon(Icons.close, color: AppColors.errorAlert),
                          label: const Text('Tolak', style: TextStyle(color: AppColors.errorAlert, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.errorAlert),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  setModalState(() => isProcessing = true);
                                  final navigator = Navigator.of(ctx);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final res = await ApiService.verifyStandard(
                                    id: item.id,
                                    penyuluhId: _userSession?.userId ?? 2,
                                    status: 'verified',
                                    catatanPenyuluh: notesCtrl.text.trim(),
                                  );
                                  if (mounted) {
                                    navigator.pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(res['message']?.toString() ?? 'Standar berhasil diverifikasi'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                    _loadPendingSubmissions();
                                  }
                                },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Setujui (Verify)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParamComparisonTable(StandarKomoditasModel item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Min Standar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Max Standar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          _buildTableRow('pH Tanah', item.minPh.toString(), item.maxPh.toString()),
          _buildTableRow('Kelembaban (%)', '${item.minMoisture.toInt()}%', '${item.maxMoisture.toInt()}%'),
          _buildTableRow('Nitrogen (N)', '${item.minN} mg/kg', '${item.maxN} mg/kg'),
          _buildTableRow('Fosfor (P)', '${item.minP} mg/kg', '${item.maxP} mg/kg'),
          _buildTableRow('Kalium (K)', '${item.minK} mg/kg', '${item.maxK} mg/kg'),
          _buildTableRow('Suhu Tanah', '${item.minTemp}°C', '${item.maxTemp}°C'),
          _buildTableRow('EC Listrik', '${item.minEc} us', '${item.maxEc} us'),
          _buildTableRow('Fertility / Salinitas', item.minFertility.toString(), item.maxFertility.toString()),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String param, String min, String max) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(param, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        Padding(padding: const EdgeInsets.all(8), child: Text(min, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(max, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Kotak Verifikasi Standar',
          style: AppTypography.headlineSm.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Assigned Village Profile Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WILAYAH BINAAN PENYULUH (1 DESA = 1 PENYULUH)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Desa ${_assignedVillage.desa}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kecamatan ${_assignedVillage.kecamatan}, Kab. Sumenep',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _changeAssignedVillage,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  child: const Text('Ganti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Pending List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.pending_actions, size: 20, color: AppColors.tertiaryAmber),
                const SizedBox(width: 8),
                Text(
                  'Pengajuan Menunggu Evaluasi (${_pendingList.length})',
                  style: AppTypography.headlineSm.copyWith(fontSize: 15),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                  onPressed: _loadPendingSubmissions,
                  tooltip: 'Muat Ulang',
                ),
              ],
            ),
          ),

          // Pending List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _pendingList.isEmpty
                    ? Center(
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
                                child: const Icon(Icons.done_all, size: 48, color: AppColors.primary),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Semua Pengajuan Telah Ditinjau',
                                style: AppTypography.headlineSm.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tidak ada pengajuan standar baru dari petani di Desa ${_assignedVillage.desa}.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPendingSubmissions,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pendingList.length,
                          itemBuilder: (ctx, i) {
                            final item = _pendingList[i];
                            return _buildPendingCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(StandarKomoditasModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusDeficitBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.komoditas,
                        style: AppTypography.headlineSm.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Varietas: ${item.varietas}',
                        style: AppTypography.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusDeficitBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top, color: AppColors.statusDeficitText, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Pending',
                        style: TextStyle(
                          color: AppColors.statusDeficitText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Diajukan oleh: ${item.namaPetani ?? "Petani Desa"} (${item.noHpPetani ?? "-"})',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildSmallPill('pH', '${item.minPh}-${item.maxPh}'),
                _buildSmallPill('Moist', '${item.minMoisture.toInt()}-${item.maxMoisture.toInt()}%'),
                _buildSmallPill('N', '${item.minN}-${item.maxN}'),
                _buildSmallPill('P', '${item.minP}-${item.maxP}'),
                _buildSmallPill('K', '${item.minK}-${item.maxK}'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showVerificationDialog(item),
                icon: const Icon(Icons.fact_check, size: 18),
                label: const Text('Tinjau & Verifikasi Standar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPill(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $val', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
