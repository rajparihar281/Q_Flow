import 'package:q_flow/data/dummy/dummy_data.dart';
import 'package:q_flow/data/models/patient_model.dart';
import 'package:q_flow/core/constants/app_constants.dart';

/// Repository for patient/profile data.
///
/// [FUTURE BACKEND] Replace with authenticated API calls:
///   GET /api/v1/patient/profile — fetch profile
///   POST /api/v1/auth/otp/send — send OTP
///   POST /api/v1/auth/otp/verify — verify OTP, get session token
class PatientRepository {
  Future<PatientModel> getPatientProfile() async {
    // [FUTURE BACKEND] GET /patient/profile (with auth header)
    await Future.delayed(AppDurations.simulatedNetwork);
    return dummyPatient;
  }

  Future<bool> sendOtp(String abhaId) async {
    // [FUTURE BACKEND] POST /auth/otp/send  {abhaId: "..."}
    await Future.delayed(AppDurations.simulatedNetwork);
    return true; // Always succeeds for demo
  }

  Future<bool> verifyOtp(String abhaId, String otp) async {
    // [FUTURE BACKEND] POST /auth/otp/verify  {abhaId: "...", otp: "..."}
    // Returns: { token: "jwt...", patient: {...} }
    await Future.delayed(AppDurations.simulatedNetwork);
    return true; // Accept any OTP for demo
  }
}
