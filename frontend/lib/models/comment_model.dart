class CommentModel {
  const CommentModel({
    required this.id,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.userImage,
  });

  final int id;
  final int userId;
  final String comment;
  final DateTime createdAt;
  final String userName;
  final String? userImage;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};

    return CommentModel(
      id: json['id'] as int,
      userId: userJson['id'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: userJson['name'] as String? ?? 'Bilinmeyen kullanıcı',
      userImage: userJson['image'] as String?,
    );
  }

  CommentModel copyWith({String? comment}) {
    return CommentModel(
      id: id,
      userId: userId,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      userName: userName,
      userImage: userImage,
    );
  }
}
