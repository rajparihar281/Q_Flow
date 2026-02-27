class PatientModel {
  final String id;
  final String abhaId;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String address;
  final List<String> medicalAlerts;
  final List<String> allergies;
  final String emergencyContact;
  final String emergencyPhone;

  const PatientModel({
    required this.id,
    required this.abhaId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.address,
    required this.medicalAlerts,
    required this.allergies,
    required this.emergencyContact,
    required this.emergencyPhone,
  });

  /// Age derived from date of birth string (dd/MM/YYYY).
  int get age {
    final parts = dateOfBirth.split('/');
    if (parts.length != 3) return 0;
    final dob = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  String get initials {
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
