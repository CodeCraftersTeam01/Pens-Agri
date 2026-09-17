import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_session_service.dart';
import '../../models/standar_komoditas_model.dart';

class CreatePostDialog extends StatefulWidget {
  final List<StandarKomoditasModel> availableStandards;
  final VoidCallback onPostCreated;

  const CreatePostDialog({
    super.key,
    required this.availableStandards,
    required this.onPostCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required List<StandarKomoditasModel> availableStandards,
    required VoidCallback onPostCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreatePostDialog(
        availableStandards: availableStandards,
        onPostCreated: onPostCreated,
      ),
    );
  }

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  StandarKomoditasModel? _selectedStandard;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final session = await UserSessionService.getSession();
    final result = await ApiService.createForumPost(
      userId: session.userId,
      standarId: _selectedStandard?.id,
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onPostCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil dibagikan ke Forum Petani!'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Gagal membuat postingan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
        key: _formKey,
        child: Column(
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
                  child: const Icon(Icons.forum, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tulis Diskusi Baru',
                        style: AppTypography.headlineSm.copyWith(fontSize: 18),
                      ),
                      Text(
                        'Bagikan pengalaman & standar tanaman ke sesama petani',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Judul Topik Diskusi',
                        hintText: 'Contoh: Pengalaman Tanam Jagung Madura di Musim Kemarau',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _bodyCtrl,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Isi Cerita / Pertanyaan / Pengalaman',
                        hintText: 'Tuliskan kondisi lahan, pemupukan NPK, atau kendala hama...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Isi postingan wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Option to attach standard
                    Text(
                      'Lampirkan Standar Komoditas (Opsional):',
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<StandarKomoditasModel?>(
                          value: _selectedStandard,
                          isExpanded: true,
                          hint: const Text('Pilih standar tanah untuk dibagikan...'),
                          items: [
                            const DropdownMenuItem<StandarKomoditasModel?>(
                              value: null,
                              child: Text('Tanpa Lampiran Standar'),
                            ),
                            ...widget.availableStandards.map((std) {
                              return DropdownMenuItem<StandarKomoditasModel?>(
                                value: std,
                                child: Row(
                                  children: [
                                    Icon(
                                      std.isVerified ? Icons.verified : Icons.warning_amber,
                                      size: 16,
                                      color: std.isVerified ? AppColors.primary : AppColors.tertiaryAmber,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${std.komoditas} - ${std.varietas} (${std.status.toUpperCase()})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedStandard = val);
                          },
                        ),
                      ),
                    ),

                    if (_selectedStandard != null && !_selectedStandard!.isVerified) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.statusDeficitBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.statusDeficitBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: AppColors.statusDeficitText, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Standar ini berstatus pending. Di forum akan otomatis diberi peringatan "Belum diverifikasi penyuluh".',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.statusDeficitText,
                                  fontWeight: FontWeight.w500,
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
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim ke Forum Komunitas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
