class UserModel {
  final String id;
  final String name;
  final String email;
  final String type;
  final bool isBanned;
  final String profilePictureUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.isBanned,
    required this.profilePictureUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      name: data['name'],
      email: data['email'],
      type: data['type'],
      isBanned: data['isBanned'] ?? false,
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }
}
