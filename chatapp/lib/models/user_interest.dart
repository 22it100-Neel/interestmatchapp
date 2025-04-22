class UserInterest {
  final String id;
  final String name;
  final List<String> interests;

  UserInterest({
    required this.id,
    required this.name,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'interests': interests,
    };
  }

  factory UserInterest.fromMap(Map<String, dynamic> map) {
    return UserInterest(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
} 