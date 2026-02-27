class AppointmentModel {
  final String id;
  final String bookingId;
  final String doctorName;
  final String hospitalName;
  final String specialization;
  final DateTime dateTime;
  final String severity;
  final String symptoms;
  final AppointmentStatus status;
  final int? tokenNumber;

  const AppointmentModel({
    required this.id,
    required this.bookingId,
    required this.doctorName,
    required this.hospitalName,
    required this.specialization,
    required this.dateTime,
    required this.severity,
    required this.symptoms,
    required this.status,
    this.tokenNumber,
  });

  AppointmentModel copyWith({AppointmentStatus? status, DateTime? dateTime}) {
    return AppointmentModel(
      id: id,
      bookingId: bookingId,
      doctorName: doctorName,
      hospitalName: hospitalName,
      specialization: specialization,
      dateTime: dateTime ?? this.dateTime,
      severity: severity,
      symptoms: symptoms,
      status: status ?? this.status,
      tokenNumber: tokenNumber,
    );
  }
}

enum AppointmentStatus { upcoming, completed, cancelled }

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
