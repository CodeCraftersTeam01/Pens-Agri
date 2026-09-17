import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/sumenep_master_data.dart';
import '../../models/wilayah_model.dart';

class SumenepLocationPickerDialog extends StatefulWidget {
  final String? initialDesa;
  final Function(DesaModel selectedDesa) onSelected;

  const SumenepLocationPickerDialog({
    super.key,
    this.initialDesa,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialDesa,
    required Function(DesaModel selectedDesa) onSelected,
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

  @override
  void initState() {
    super.initState();
    _loadWilayah();
  }

  Future<void> _loadWilayah() async {
    List<DesaModel> list = await ApiService.getSumenepWilayah();
    if (list.isEmpty) {
      list = SumenepMasterData.offlineDesaList;
    }
    if (mounted) {
      setState(() {
        _allDesa = list;
        _filteredDesa = list;
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty || _searchQuery == 'sumenep' || _searchQuery == 'kabupaten sumenep') {
        _filteredDesa = _allDesa;
      } else {
        _filteredDesa = _allDesa.where((d) {
          return d.desa.toLowerCase().contains(_searchQuery) ||
              d.kecamatan.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
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
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                  child: const Icon(Icons.location_city, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Desa Binaan Penyuluh',
                        style: AppTypography.headlineSm.copyWith(fontSize: 17),
                      ),
                      Text(
                        'Strict Invariant: 1 Penyuluh per 1 Desa Sumenep',
                        style: AppTypography.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredDesa.isEmpty
                    ? Center(
                        child: Text(
                          'Desa tidak ditemukan di Kabupaten Sumenep',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDesa.length,
                        itemBuilder: (ctx, i) {
                          final item = _filteredDesa[i];
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.pin_drop, size: 18, color: AppColors.primary),
                            ),
                            title: Text(item.desa, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('Kecamatan ${item.kecamatan}, Kab. Sumenep', style: AppTypography.bodySm),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                            onTap: () {
                              widget.onSelected(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
