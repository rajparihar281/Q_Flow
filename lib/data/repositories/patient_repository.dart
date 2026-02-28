import 'package:q_flow/core/config/api_config.dart';
import 'package:q_flow/core/services/api_service.dart';
import 'package:q_flow/data/models/patient_model.dart';
import 'package:q_flow/core/utils/session_manager.dart';

class PatientRepository {
  Future<List<PatientModel>> getAllPatients() async {
    final response = await ApiService.get(ApiConfig.patients);
    final List data = response['data'] ?? [];
    return data
        .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    final response = await ApiService.get(ApiConfig.patientById(id));
    return PatientModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<PatientModel> getPatientByAbhaId(String abhaId) async {
    final response = await ApiService.get(ApiConfig.patientByAbha(abhaId));
    return PatientModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Get current logged-in patient profile using session
  Future<PatientModel> getPatientProfile() async {
    final patientId = SessionManager.getPatientId();
    if (patientId != null) {
      return getPatientById(patientId);
    }
    // Fallback: get first patient and save id
    final patients = await getAllPatients();
    if (patients.isEmpty) {
      throw Exception('No patients found');
    }
    SessionManager.setPatientId(patients.first.id);
    return patients.first;
  }

  /// OTP flow stubs — replace with real OTP endpoint if needed
  Future<bool> sendOtp(String abhaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> verifyOtp(String abhaId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Look up patient by ABHA ID and store session
      final patient = await getPatientByAbhaId(abhaId);
      SessionManager.setPatientId(patient.id);
    } catch (_) {
      // If patient not found, still allow login for demo
      final patients = await getAllPatients();
      if (patients.isNotEmpty) {
        SessionManager.setPatientId(patients.first.id);
      }
    }
    return true;
  }
}
