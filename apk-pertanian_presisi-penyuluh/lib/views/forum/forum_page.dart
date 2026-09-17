import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/forum_model.dart';
import 'create_post_dialog.dart';
import 'post_detail_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<ForumPostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    final posts = await ApiService.getForumPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  void _openCreatePost() {
    CreatePostDialog.show(
      context,
      onPostCreated: _loadFeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.forum, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Forum Komunikasi Tani',
              style: AppTypography.headlineSm.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign),
        label: const Text('Buat Arahan Penyuluh'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _posts.isEmpty
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
                          child: const Icon(Icons.forum_outlined, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Forum Belum Ada Postingan',
                          style: AppTypography.headlineSm.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bagikan tips budidaya dan rekomendasi nutrisi tanah kepada petani di wilayah binaan Anda.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _openCreatePost,
                          icon: const Icon(Icons.campaign),
                          label: const Text('Tulis Arahan Pertama'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                    itemCount: _posts.length,
                    itemBuilder: (ctx, i) {
                      final post = _posts[i];
                      return _buildPostCard(post);
                    },
                  ),
                ),
    );
  }

  Widget _buildPostCard(ForumPostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => PostDetailPage(
                postId: post.id,
                initialPost: post,
              ),
            ),
          ).then((_) => _loadFeed());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Info Bar
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: post.author.isPenyuluh ? AppColors.primary : AppColors.secondary,
                    child: Icon(
                      post.author.isPenyuluh ? Icons.verified_user : Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.author.name,
                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (post.author.isPenyuluh)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Penyuluh',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${post.author.desa ?? "Sumenep"}, Kec. ${post.author.kecamatan ?? "Sumenep"}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Body
              Text(
                post.title,
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),

              // Attached Standard Snippet
              if (post.hasAttachedStandard && post.attachedStandard != null) ...[
                const SizedBox(height: 12),
                _buildAttachedStandardPreview(post),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              const SizedBox(height: 8),

              // Footer: Comments Count
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.outline),
                  const SizedBox(width: 6),
                  Text(
                    '${post.totalComments} Tanggapan',
                    style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                  ),
                  const Spacer(),
                  Text(
                    'Beri Arahan & Komentar →',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachedStandardPreview(ForumPostModel post) {
    final std = post.attachedStandard!;
    final isVerified = post.isVerified || std.isVerified;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.statusDeficitBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isVerified
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.tertiaryAmber,
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
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Standar Lampiran Petani: ${std.komoditas} (${std.varietas})',
                  style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          // Prominent warning if unverified
          if (!isVerified) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusDeficitBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.statusDeficitBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.statusDeficitText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Standar ini belum diverifikasi penyuluh',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.statusDeficitText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
