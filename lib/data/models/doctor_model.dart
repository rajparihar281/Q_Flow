class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String department;
  final String phone;
  final String email;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.department,
    required this.phone,
    required this.email,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  // No hospital, no rating, no available_today in real DB
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
