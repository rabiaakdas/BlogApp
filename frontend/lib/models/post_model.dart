class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.userName,
    required this.commentsCount,
    required this.likesCount,
    required this.isLiked,
    this.image,
    this.userImage,
  });

  final int id;
  final int userId;
  final String body;
  final String? image;
  final DateTime createdAt;
  final String userName;
  final String? userImage;
  final int commentsCount;
  final int likesCount;
  final bool isLiked;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final likes = json['likes'] as List<dynamic>? ?? [];

    return PostModel(
      id: json['id'] as int,
      userId: userJson['id'] as int? ?? 0,
      body: json['body'] as String? ?? '',
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName:
          userJson['name'] as String? ??
          json['username'] as String? ??
          json['user_name'] as String? ??
          'Bilinmeyen kullanıcı',
      userImage: userJson['image'] as String?,
      commentsCount: json['comments_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: likes.isNotEmpty,
    );
  }

  PostModel copyWith({int? commentsCount, int? likesCount, bool? isLiked}) {
    return PostModel(
      id: id,
      userId: userId,
      body: body,
      image: image,
      createdAt: createdAt,
      userName: userName,
      userImage: userImage,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
