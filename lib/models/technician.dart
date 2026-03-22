// lib/models/technician.dart
class Technician {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final bool isAvailable;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'isAvailable': isAvailable,
    };
  }

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      specialization: json['specialization'],
      isAvailable: json['isAvailable'],
    );
  }
}
