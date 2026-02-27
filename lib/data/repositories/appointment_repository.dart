import 'package:q_flow/data/dummy/dummy_data.dart';
import 'package:q_flow/data/models/appointment_model.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/utils/app_utils.dart';

/// In-memory appointment store for the session.
/// Starts with dummy history and accumulates new bookings.
///
/// [FUTURE BACKEND] Replace with HTTP calls:
///   POST /api/v1/appointments — create
///   GET  /api/v1/appointments?patientId=xx — list
///   PUT  /api/v1/appointments/:id/cancel — cancel
class AppointmentRepository {
  final List<AppointmentModel> _appointments = List.from(
    dummyAppointmentHistory,
  );

  Future<List<AppointmentModel>> getAppointmentHistory() async {
    // [FUTURE BACKEND] GET /appointments?patientId=...
    await Future.delayed(AppDurations.simulatedNetwork);
    return List.from(_appointments.reversed.toList());
  }

  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    // [FUTURE BACKEND] GET /appointments?patientId=...&status=upcoming
    await Future.delayed(AppDurations.simulatedNetwork);
    return _appointments
        .where((a) => a.status == AppointmentStatus.upcoming)
        .toList()
        .reversed
        .toList();
  }

  Future<AppointmentModel> bookAppointment({
    required String doctorName,
    required String hospitalName,
    required String specialization,
    required DateTime dateTime,
    required String severity,
    required String symptoms,
  }) async {
    // [FUTURE BACKEND] POST /appointments — send payload, receive bookingId + token
    await Future.delayed(AppDurations.simulatedNetwork);

    final appointment = AppointmentModel(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      bookingId: AppUtils.generateBookingId(),
      doctorName: doctorName,
      hospitalName: hospitalName,
      specialization: specialization,
      dateTime: dateTime,
      severity: severity,
      symptoms: symptoms,
      status: AppointmentStatus.upcoming,
      tokenNumber: 44 + _appointments.length + 1,
    );

    _appointments.add(appointment);
    return appointment;
  }

  Future<bool> cancelAppointment(String id) async {
    // [FUTURE BACKEND] PUT /appointments/$id/cancel
    await Future.delayed(AppDurations.simulatedNetwork);
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    _appointments[idx] = _appointments[idx].copyWith(
      status: AppointmentStatus.cancelled,
    );
    return true;
  }

  Future<bool> rescheduleAppointment(String id, DateTime newDateTime) async {
    // [FUTURE BACKEND] PUT /appointments/$id/reschedule
    await Future.delayed(AppDurations.simulatedNetwork);
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    _appointments[idx] = _appointments[idx].copyWith(
      dateTime: newDateTime,
    );
    return true;
  }
}
