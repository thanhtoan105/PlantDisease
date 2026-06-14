class UserProfile {
  final String id;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String email; // Read-only from auth

  UserProfile({
    required this.id,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      dateOfBirth: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'],
      address: json['address'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'dob': dateOfBirth?.toIso8601String().split('T')[0], // Format as date only
      'gender': gender,
      'address': address,
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      email: email ?? this.email,
    );
  }
}
