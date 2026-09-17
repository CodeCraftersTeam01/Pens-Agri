import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/user_session_service.dart';
import '../auth/login_page.dart';
import '../widgets/sumenep_location_picker_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserSession? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await UserSessionService.getSession();
    if (mounted) {
      setState(() {
        _session = session;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Penyuluh ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorAlert,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserSessionService.clearSession();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  void _changeVillage() {
    if (_session == null) return;
    SumenepLocationPickerDialog.show(
      context,
      initialDesa: _session!.desaName,
      onSelected: (desa) async {
        final updated = UserSession(
          userId: _session!.userId,
          name: _session!.name,
          role: _session!.role,
          desaId: desa.id,
          desaName: desa.desa,
          kecamatanName: desa.kecamatan,
          phone: _session!.phone,
          nik: _session!.nik,
          email: _session!.email,
        );
        await UserSessionService.saveSession(updated);
        _loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wilayah binaan diperbarui: Desa ${desa.desa}, Kec. ${desa.kecamatan}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Penyuluh'),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.badge, size: 50, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _session?.name ?? 'Penyuluh Pertanian',
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.statusOptimalBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.statusOptimalBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 16, color: AppColors.statusOptimalText),
                              const SizedBox(width: 4),
                              Text(
                                'Penyuluh Resmi Dinas Pertanian Sumenep',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.statusOptimalText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.badge_outlined,
                            label: 'NIP / NIK Petugas',
                            value: _session?.nik.isNotEmpty == true ? _session!.nik : '3529xxxxxxxxxxxx',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.phone_android,
                            label: 'No. WhatsApp / Kontak Dinas',
                            value: _session?.phone.isNotEmpty == true ? _session!.phone : '-',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email Dinas',
                            value: _session?.email.isNotEmpty == true ? _session!.email : '-',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.location_city,
                            label: 'Desa Binaan (1 Desa = 1 Penyuluh)',
                            value: 'Desa ${_session?.desaName}, Kec. ${_session?.kecamatanName}',
                            trailing: TextButton(
                              onPressed: _changeVillage,
                              child: const Text('Ubah'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsibility Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Tugas Pokok Penyuluh',
                                style: AppTypography.headlineSm.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '• Melakukan audit dan verifikasi pengajuan standar tanaman dari petani di Desa ${_session?.desaName}.\n• Memantau indikator NPK, pH, kelembaban, dan salinitas tanah.\n• Memberikan arahan dan panduan teknis melalui Forum Komunitas.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: AppColors.errorAlert),
                      label: const Text(
                        'Keluar dari Akun Penyuluh',
                        style: TextStyle(
                          color: AppColors.errorAlert,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.errorAlert),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Text(
                value,
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
