import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/forum_model.dart';
import '../../models/standar_komoditas_model.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  final ForumPostModel initialPost;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.initialPost,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late ForumPostModel _post;
  bool _isLoading = true;
  final _commentCtrl = TextEditingController();
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _loadFullPost();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFullPost() async {
    final detail = await ApiService.getForumPostDetail(widget.postId);
    if (mounted) {
      setState(() {
        if (detail != null) _post = detail;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);
    final result = await ApiService.addForumComment(
      postId: widget.postId,
      userId: 2, // Default local Penyuluh ID
      comment: text,
    );

    if (mounted) {
      setState(() => _isSendingComment = false);
      if (result['success'] == true) {
        _commentCtrl.clear();
        _loadFullPost();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Gagal mengirim komentar'),
            backgroundColor: AppColors.errorAlert,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Detail Diskusi Forum',
          style: AppTypography.headlineSm.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _loadFullPost,
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildPostMainCard(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.forum_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Komentar (${_post.comments.length})',
                              style: AppTypography.headlineSm.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_post.comments.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: Text(
                              'Belum ada tanggapan. Berikan panduan penyuluh pertama!',
                              style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                            ),
                          )
                        else
                          ..._post.comments.map((c) => _buildCommentTile(c)),
                      ],
                    ),
                  ),
          ),

          // Bottom Comment Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tulis arahan / evaluasi teknis penyuluh...',
                      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSendingComment ? null : _sendComment,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSendingComment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMainCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
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
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _post.author.isPenyuluh ? AppColors.primary : AppColors.secondary,
                child: Icon(
                  _post.author.isPenyuluh ? Icons.verified_user : Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _post.author.name,
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _post.author.isPenyuluh
                                ? AppColors.primaryFixed.withValues(alpha: 0.4)
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _post.author.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _post.author.isPenyuluh ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_post.author.desa ?? "Sumenep"}, Kec. ${_post.author.kecamatan ?? "Sumenep"}',
                      style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title & Body
          Text(
            _post.title,
            style: AppTypography.headlineSm.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            _post.body,
            style: AppTypography.bodyMd.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),

          // Attached Standard Card if available
          if (_post.hasAttachedStandard && _post.attachedStandard != null) ...[
            _buildAttachedStandardBox(_post.attachedStandard!),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachedStandardBox(StandarKomoditasModel std) {
    final isVerified = _post.isVerified || std.isVerified;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.statusDeficitBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.tertiaryAmber,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.warning_amber,
                color: isVerified ? AppColors.primary : AppColors.tertiaryAmber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Standar Lampiran: ${std.komoditas} (${std.varietas})',
                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          // Prominent Amber Warning if Unverified
          if (!isVerified) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusDeficitBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.statusDeficitBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.statusDeficitText, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Standar ini belum diverifikasi penyuluh',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.statusDeficitText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMiniParam('pH', '${std.minPh}-${std.maxPh}'),
              _buildMiniParam('Kelembaban', '${std.minMoisture.toInt()}-${std.maxMoisture.toInt()}%'),
              _buildMiniParam('N', '${std.minN}-${std.maxN}'),
              _buildMiniParam('P', '${std.minP}-${std.maxP}'),
              _buildMiniParam('K', '${std.minK}-${std.maxK}'),
              _buildMiniParam('Suhu', '${std.minTemp}-${std.maxTemp}°C'),
              _buildMiniParam('EC', '${std.minEc}-${std.maxEc}'),
              _buildMiniParam('Fertility', '${std.minFertility}-${std.maxFertility}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniParam(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCommentTile(ForumCommentModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.author.isPenyuluh
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.surfaceContainerHigh,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: c.author.isPenyuluh ? AppColors.primary : AppColors.outlineVariant,
                child: Icon(
                  c.author.isPenyuluh ? Icons.verified : Icons.person,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                c.author.name,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.author.isPenyuluh ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              if (c.author.isPenyuluh) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Penyuluh',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(c.comment, style: AppTypography.bodyMd),
        ],
      ),
    );
  }
}
