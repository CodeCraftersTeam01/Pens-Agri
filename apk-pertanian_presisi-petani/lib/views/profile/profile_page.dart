import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_session_service.dart';
import '../../models/wilayah_model.dart';
import '../auth/login_page.dart';
import '../widgets/sumenep_location_picker_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserSession? _session;
  PairedPenyuluhModel? _pairedPenyuluh;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await UserSessionService.getSession();
    final paired = await ApiService.getPairedPenyuluh(session.desaId);
    if (mounted) {
      setState(() {
        _session = session;
        _pairedPenyuluh = paired;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
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
      onSelected: (desa, penyuluh) async {
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
              content: Text('Lokasi desa diperbarui: Desa ${desa.desa}'),
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
        title: const Text('Profil Pengguna'),
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
                  // User Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _session?.name ?? 'Petani',
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
                                'Petani Terdaftar Sumenep',
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

                  // Profile Details Card
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
                            label: 'NIK KTP',
                            value: _session?.nik.isNotEmpty == true ? _session!.nik : '3529xxxxxxxxxxxx',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.phone_android,
                            label: 'No. WhatsApp / Telepon',
                            value: _session?.phone.isNotEmpty == true ? _session!.phone : '-',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _session?.email.isNotEmpty == true ? _session!.email : '-',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.location_city,
                            label: 'Desa Pertanian',
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

                  // Paired Penyuluh Card
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
                              const Icon(Icons.handshake_outlined, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Penyuluh Pendamping Desa',
                                style: AppTypography.headlineSm.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_pairedPenyuluh != null) ...[
                            Text(
                              _pairedPenyuluh!.nama,
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Kontak: ${_pairedPenyuluh!.noHp.isNotEmpty ? _pairedPenyuluh!.noHp : _pairedPenyuluh!.email}',
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ] else ...[
                            Text(
                              'Penyuluh untuk Desa ${_session?.desaName} siap memverifikasi pengajuan standar dan memonitor data sensor Anda.',
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
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
                        'Keluar dari Akun (Logout)',
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
