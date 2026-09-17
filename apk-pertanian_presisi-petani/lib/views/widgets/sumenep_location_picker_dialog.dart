import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sumenep_master_data.dart';
import '../../core/services/api_service.dart';
import '../../models/wilayah_model.dart';

class SumenepLocationPickerDialog extends StatefulWidget {
  final String? initialDesa;
  final Function(DesaModel selectedDesa, PairedPenyuluhModel? pairedPenyuluh) onSelected;

  const SumenepLocationPickerDialog({
    super.key,
    this.initialDesa,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialDesa,
    required Function(DesaModel selectedDesa, PairedPenyuluhModel? pairedPenyuluh) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SumenepLocationPickerDialog(
        initialDesa: initialDesa,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<SumenepLocationPickerDialog> createState() => _SumenepLocationPickerDialogState();
}

class _SumenepLocationPickerDialogState extends State<SumenepLocationPickerDialog> {
  List<DesaModel> _allDesa = [];
  List<DesaModel> _filteredDesa = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DesaModel? _selected;
  PairedPenyuluhModel? _pairedPenyuluh;
  bool _isLoadingPenyuluh = false;

  @override
  void initState() {
    super.initState();
    _loadWilayah();
  }

  Future<void> _loadWilayah() async {
    final list = await ApiService.getSumenepWilayah();
    if (mounted) {
      setState(() {
        _allDesa = list.isNotEmpty ? list : SumenepMasterData.offlineDesaList;
        _filteredDesa = _allDesa;
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      if (_searchQuery.isEmpty ||
          _searchQuery == 'sumenep' ||
          _searchQuery == 'kabupaten sumenep' ||
          _searchQuery == 'kab sumenep') {
        _filteredDesa = _allDesa;
      } else {
        _filteredDesa = _allDesa.where((d) {
          return d.desa.toLowerCase().contains(_searchQuery) ||
              d.kecamatan.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _selectDesa(DesaModel desa) async {
    setState(() {
      _selected = desa;
      _isLoadingPenyuluh = true;
    });

    final penyuluh = await ApiService.getPairedPenyuluh(desa.id);
    if (mounted) {
      setState(() {
        _pairedPenyuluh = penyuluh;
        _isLoadingPenyuluh = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Indicator
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Desa / Kelurahan',
                        style: AppTypography.headlineSm.copyWith(fontSize: 17),
                      ),
                      Text(
                        'Eksklusif Wilayah Kabupaten Sumenep',
                        style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceContainerHigh),

          // Search Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari Desa atau Kecamatan di Sumenep...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Paired Penyuluh Banner if selected
          if (_selected != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.badge, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penyuluh Pendamping Desa Terpilih:',
                          style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.primary),
                        ),
                        _isLoadingPenyuluh
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _pairedPenyuluh != null
                                    ? '${_pairedPenyuluh!.nama} (${_pairedPenyuluh!.noHp})'
                                    : 'PPL Binaan UPT Pertanian Kecamatan ${_selected!.kecamatan}',
                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                              ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSelected(_selected!, _pairedPenyuluh);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Pilih', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Village List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredDesa.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: AppColors.outline),
                            const SizedBox(height: 8),
                            Text(
                              'Desa tidak ditemukan di Kabupaten Sumenep',
                              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDesa.length,
                        itemBuilder: (ctx, i) {
                          final item = _filteredDesa[i];
                          final isCurrentSelected = _selected?.id == item.id;
                          return InkWell(
                            onTap: () => _selectDesa(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isCurrentSelected
                                    ? AppColors.primary.withValues(alpha: 0.05)
                                    : Colors.transparent,
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppColors.surfaceContainerHigh,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCurrentSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.home_work,
                                      size: 16,
                                      color: isCurrentSelected ? Colors.white : AppColors.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.desa,
                                          style: AppTypography.bodyMd.copyWith(
                                            fontWeight: isCurrentSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isCurrentSelected ? AppColors.primary : AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Kecamatan ${item.kecamatan}',
                                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentSelected)
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
