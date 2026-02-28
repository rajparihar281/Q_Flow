import 'package:q_flow/core/config/api_config.dart';
import 'package:q_flow/core/services/api_service.dart';
import 'package:q_flow/data/models/appointment_model.dart';
import 'package:q_flow/core/utils/session_manager.dart';

class AppointmentRepository {
  Future<List<AppointmentModel>> getAllAppointments() async {
    final response = await ApiService.get(ApiConfig.appointments);
    final List data = response['data'] ?? [];
    return data
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByPatient(
    String patientId,
  ) async {
    final response = await ApiService.get(
      ApiConfig.appointmentsByPatient(patientId),
    );
    final List data = response['data'] ?? [];
    return data
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final response = await ApiService.get(ApiConfig.appointmentById(id));
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // Backward compatibility
  Future<List<AppointmentModel>> getAppointmentHistory() async =>
      getAllAppointments();

  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    final all = await getAllAppointments();
    return all
        .where((a) => a.status == 'upcoming' || a.status == 'scheduled')
        .toList();
  }

  Future<AppointmentModel> updateStatus(String id, String status) async {
    final response = await ApiService.patch(ApiConfig.appointmentStatus(id), {
      'status': status,
    });
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Book a new appointment. Returns a local model immediately;
  /// full backend booking needs patient_id from session.
  Future<AppointmentModel> bookAppointment({
    required String doctorName,
    required String doctorId,
    required String specialization,
    required DateTime dateTime,
    required String reason,
  }) async {
    final patientId = SessionManager.getPatientId();
    if (patientId == null) {
      throw Exception('No active session. Please log in again.');
    }

    final response = await ApiService.post(ApiConfig.appointments, {
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDatetime': dateTime.toIso8601String(),
      'reason': reason,
    });
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Reschedule stub — not yet supported by backend.
  Future<bool> rescheduleAppointment(String id, DateTime newDateTime) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return false;
  }

  Future<bool> cancelAppointment(String id) async {
    await updateStatus(id, 'cancelled');
    return true;
  }
}
