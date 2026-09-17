import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_session_service.dart';
import '../../models/wilayah_model.dart';
import '../home/farmer_main_shell.dart';
import '../widgets/sumenep_location_picker_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  DesaModel _selectedDesa = const DesaModel(
    id: 79,
    kecamatan: 'Gapura',
    desa: 'Gapura Barat',
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nikCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      nama: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: 'petani',
      desaId: _selectedDesa.id,
      nik: _nikCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true && result['data']?['user'] != null) {
      final user = result['data']['user'] as Map<String, dynamic>;
      final session = UserSession(
        userId: user['id'] is int ? user['id'] : int.tryParse(user['id']?.toString() ?? '1') ?? 1,
        name: user['nama']?.toString() ?? _nameCtrl.text.trim(),
        role: 'petani',
        desaId: _selectedDesa.id,
        desaName: _selectedDesa.desa,
        kecamatanName: _selectedDesa.kecamatan,
        phone: _phoneCtrl.text.trim(),
        nik: _nikCtrl.text.trim(),
        email: user['email']?.toString() ?? '',
      );

      await UserSessionService.saveSession(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pendaftaran berhasil! Terhubung dengan Desa ${_selectedDesa.desa}.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const FarmerMainShell()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Pendaftaran gagal'),
          backgroundColor: AppColors.errorAlert,
          action: SnackBarAction(
            label: 'Daftar Lokal',
            textColor: Colors.white,
            onPressed: _saveLocalAndProceed,
          ),
        ),
      );
    }
  }

  Future<void> _saveLocalAndProceed() async {
    final session = UserSession(
      userId: DateTime.now().millisecondsSinceEpoch % 100000,
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Petani Sumenep',
      role: 'petani',
      desaId: _selectedDesa.id,
      desaName: _selectedDesa.desa,
      kecamatanName: _selectedDesa.kecamatan,
      phone: _phoneCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
    );
    await UserSessionService.saveSession(session);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FarmerMainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pendaftaran Petani'),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrasi Petani Kabupaten Sumenep',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Akun akan dipasangkan otomatis dengan Penyuluh Pertanian di desa yang Anda pilih.',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Form
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColors.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap Petani',
                            hintText: 'Contoh: Ahmad Fauzi',
                            prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        // WhatsApp / Phone
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Nomor WhatsApp / Telepon',
                            hintText: '081234567890',
                            prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        // NIK
                        TextFormField(
                          controller: _nikCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          decoration: InputDecoration(
                            labelText: 'NIK KTP (16 Digit)',
                            hintText: '3529xxxxxxxxxxxx',
                            counterText: '',
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                            if (v.trim().length < 16) return 'NIK harus 16 digit';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Village Picker
                        Text(
                          'Lokasi Desa Pertanian di Sumenep:',
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
                                const Icon(Icons.chevron_right, color: AppColors.outline),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi Baru',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.outline,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Daftar Akun Petani',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
