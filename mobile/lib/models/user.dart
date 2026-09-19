class AppUser {
  final int userId;
  final String fullName;
  final String email;

  AppUser({required this.userId, required this.fullName, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
      };
}
