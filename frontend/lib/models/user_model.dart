class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
  });

  final int id;
  final String name;
  final String email;
  final String? image;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'image': image};
  }
}
