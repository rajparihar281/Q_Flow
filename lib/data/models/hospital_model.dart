class HospitalModel {
  final String id;
  final String name;
  final String distance;
  final double rating;
  final String specialities;
  final String address;
  final String phone;
  final List<DoctorModel> doctors;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
    required this.specialities,
    required this.address,
    required this.phone,
    required this.doctors,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final bool availableToday;
  final String availability;
  final String hospitalId;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.availableToday,
    required this.availability,
    required this.hospitalId,
  });

  /// Returns initials from last name for avatar display.
  String get initial {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.last[0].toUpperCase();
  }
}
