import 'standar_komoditas_model.dart';

class ForumAuthorModel {
  final int id;
  final String name;
  final String role; // 'petani' or 'penyuluh'
  final String? photo;
  final String? kecamatan;
  final String? desa;

  const ForumAuthorModel({
    required this.id,
    required this.name,
    required this.role,
    this.photo,
    this.kecamatan,
    this.desa,
  });

  bool get isPenyuluh => role.toLowerCase() == 'penyuluh';

  factory ForumAuthorModel.fromJson(Map<String, dynamic> json) {
    return ForumAuthorModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Petani Sumenep',
      role: json['role']?.toString().toLowerCase() ?? 'petani',
      photo: json['photo']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      desa: json['desa']?.toString(),
    );
  }
}

class ForumCommentModel {
  final int id;
  final String comment;
  final DateTime createdAt;
  final ForumAuthorModel author;

  const ForumCommentModel({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.author,
  });

  factory ForumCommentModel.fromJson(Map<String, dynamic> json) {
    return ForumCommentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      author: ForumAuthorModel.fromJson(json['author'] is Map<String, dynamic> ? json['author'] : {}),
    );
  }
}

class ForumPostModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final ForumAuthorModel author;
  final bool hasAttachedStandard;
  final bool isVerified;
  final String? verificationStatus;
  final String? verificationWarning;
  final StandarKomoditasModel? attachedStandard;
  final List<ForumCommentModel> comments;
  final int totalComments;

  const ForumPostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.author,
    required this.hasAttachedStandard,
    required this.isVerified,
    this.verificationStatus,
    this.verificationWarning,
    this.attachedStandard,
    this.comments = const [],
    required this.totalComments,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    final attachedStdJson = json['attached_standard'];
    StandarKomoditasModel? attachedStd;
    if (attachedStdJson is Map<String, dynamic> && attachedStdJson.isNotEmpty) {
      attachedStd = StandarKomoditasModel.fromJson(attachedStdJson);
    }

    final commentsListJson = json['comments'] as List<dynamic>? ?? [];
    final comments = commentsListJson
        .map((c) => ForumCommentModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ForumPostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      author: ForumAuthorModel.fromJson(json['author'] is Map<String, dynamic> ? json['author'] : {}),
      hasAttachedStandard: json['has_attached_standard'] == true || attachedStd != null,
      isVerified: json['is_verified'] == true,
      verificationStatus: json['verification_status']?.toString(),
      verificationWarning: json['verification_warning']?.toString(),
      attachedStandard: attachedStd,
      comments: comments,
      totalComments: json['total_comments'] is int
          ? json['total_comments']
          : int.tryParse(json['total_comments']?.toString() ?? '') ?? comments.length,
    );
  }
}
