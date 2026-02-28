class QueueModel {
  final String id;
  final String appointmentId;
  final int tokenNumber;
  final String queueDate;
  final String status;
  final String? calledAt;
  final String? completedAt;
  // Joined via appointment → patient/doctor
  final String patientName;
  final String? patientId;
  final String? gender;
  final String? doctorName;
  final String? specialization;
  final String? reason;
  final int? priorityScore;
  final bool? aiFlag;

  const QueueModel({
    required this.id,
    required this.appointmentId,
    required this.tokenNumber,
    required this.queueDate,
    required this.status,
    this.calledAt,
    this.completedAt,
    required this.patientName,
    this.patientId,
    this.gender,
    this.doctorName,
    this.specialization,
    this.reason,
    this.priorityScore,
    this.aiFlag,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return QueueModel(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString() ?? '',
      tokenNumber: parseInt(json['token_number']),
      queueDate: json['queue_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      calledAt: json['called_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      patientName: json['patient_name']?.toString() ?? '',
      patientId: json['patient_id']?.toString(),
      gender: json['gender']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      specialization: json['specialization']?.toString(),
      reason: json['reason']?.toString(),
      priorityScore: parseInt(json['priority_score']),
      aiFlag: json['ai_flag'] == true,
    );
  }

  bool get isWaiting => status == 'waiting';
  bool get isCalled => status == 'called';
  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';

  /// No booking_id or severity in real queue table — graceful compat
  String? get bookingId => appointmentId.length > 8
      ? appointmentId.substring(0, 8).toUpperCase()
      : appointmentId;
  String? get severity => null;
}
