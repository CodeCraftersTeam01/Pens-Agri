import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/user_session_service.dart';
import '../../models/wilayah_model.dart';
import 'sumenep_location_picker_dialog.dart';

class OnboardingProfileDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const OnboardingProfileDialog({super.key, required this.onSaved});

  static Future<void> checkAndShow(BuildContext context, {required VoidCallback onSaved}) async {
    final hasSession = await UserSessionService.hasCustomSession();
    if (!hasSession && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => OnboardingProfileDialog(onSaved: onSaved),
      );
    }
  }

  @override
  State<OnboardingProfileDialog> createState() => _OnboardingProfileDialogState();
}

class _OnboardingProfileDialogState extends State<OnboardingProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Petani Madura');
  DesaModel _selectedDesa = const DesaModel(
    id: 79,
    kecamatan: 'Gapura',
    desa: 'Gapura Barat',
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final session = UserSession(
      userId: 1,
      name: _nameCtrl.text.trim(),
      role: 'petani',
      desaId: _selectedDesa.id,
      desaName: _selectedDesa.desa,
      kecamatanName: _selectedDesa.kecamatan,
    );

    await UserSessionService.saveSession(session);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context, rootNavigator: true).pop();
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${session.name}! Lokasi lahan diset di Desa ${session.selectedDesaName}.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_pin, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Petani Sumenep',
                            style: AppTypography.headlineSm.copyWith(fontSize: 18),
                          ),
                          Text(
                            'Lengkapi identitas untuk terhubung dengan Penyuluh',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap Petani',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'Lokasi Lahan Pertanian (Kabupaten Sumenep):',
                  style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                InkWell(
                  onTap: () {
                    SumenepLocationPickerDialog.show(
                      context,
                      initialDesa: _selectedDesa.desa,
                      onSelected: (desa, penyuluh) {
                        setState(() {
                          _selectedDesa = desa;
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Desa ${_selectedDesa.desa}',
                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Kecamatan ${_selectedDesa.kecamatan}, Kab. Sumenep',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_location_alt, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan & Mulai Aplikasi',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
