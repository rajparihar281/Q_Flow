class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDatetime;
  final String status;
  final String reason;
  final int priorityScore;
  final int estimatedWaitMinutes;
  final bool aiFlag;
  // Joined fields from backend
  final String? doctorName;
  final String? specialization;
  final String? patientName;
  final int? _dbTokenNumber;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDatetime,
    required this.status,
    required this.reason,
    required this.priorityScore,
    required this.estimatedWaitMinutes,
    required this.aiFlag,
    this.doctorName,
    this.specialization,
    this.patientName,
    int? dbTokenNumber,
  }) : _dbTokenNumber = dbTokenNumber;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      appointmentDatetime:
          DateTime.tryParse(json['appointment_datetime']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'scheduled',
      reason: json['reason']?.toString() ?? '',
      priorityScore: parseInt(json['priority_score']),
      estimatedWaitMinutes: parseInt(json['estimated_wait_minutes']),
      aiFlag: json['ai_flag'] == true,
      doctorName: json['doctor_name']?.toString(),
      specialization: json['specialization']?.toString(),
      patientName: json['patient_name']?.toString(),
      dbTokenNumber: json['token_number'] != null
          ? parseInt(json['token_number'])
          : null,
    );
  }

  // Backward compatibility getters for existing screens
  DateTime get dateTime => appointmentDatetime;
  String get symptoms => reason;
  String get label => _statusLabel(status);

  // No booking_id/token_number/severity/hospitalName in real DB — compat fallbacks
  String get bookingId =>
      id.length >= 8 ? 'QF-${id.substring(0, 8).toUpperCase()}' : id;
  // Fallback token number generated from ID hash to avoid #null rendering
  int get tokenNumber => _dbTokenNumber ?? (id.hashCode.abs() % 1000);
  String get severity => 'Medium'; // Default fallback
  String get hospitalName => 'Q-Flow Central Medical Center';
  String get doctorNameOrEmpty => doctorName ?? 'Assigned Doctor';
  String get specializationOrEmpty => specialization ?? 'General Practice';

  static String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'scheduled':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }
}
