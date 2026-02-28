class PatientModel {
  final String id;
  final String abhaId;
  // Real DB has 'name' column (not full_name)
  final String name;
  final String phone;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final String emergencyContact;
  // Aggregated from medical_alerts table
  final List<Map<String, dynamic>> medicalAlerts;

  const PatientModel({
    required this.id,
    required this.abhaId,
    required this.name,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.emergencyContact,
    required this.medicalAlerts,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseAlerts(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map(
              (e) =>
                  e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{},
            )
            .toList();
      }
      return [];
    }

    return PatientModel(
      id: json['id']?.toString() ?? '',
      abhaId: json['abha_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      emergencyContact: json['emergency_contact']?.toString() ?? '',
      medicalAlerts: parseAlerts(json['medical_alerts']),
    );
  }

  // Backward compatibility getters
  String get fullName => name;

  int get age {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int years = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        years--;
      }
      return years;
    } catch (_) {
      return 0;
    }
  }

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  /// Alert types as a simple string list (for UI display)
  List<String> get alertTypes =>
      medicalAlerts.map((a) => a['alert_type']?.toString() ?? '').toList();

  // ── Compat getters for removed fields ──
  /// No allergies table in real DB
  List<String> get allergies => [];

  /// No emergency_phone column in real DB
  String get emergencyPhone => '';
}
