import 'package:q_flow/data/dummy/dummy_data.dart';
import 'package:q_flow/data/models/hospital_model.dart';
import 'package:q_flow/core/constants/app_constants.dart';

/// Repository for hospital and doctor data.
///
/// [FUTURE BACKEND] Replace dummy data calls with HTTP requests:
///   GET /api/v1/hospitals?lat=xx&lng=yy&radius=10km
///   GET /api/v1/hospitals/:id/doctors
class HospitalRepository {
  Future<List<HospitalModel>> getNearbyHospitals() async {
    // [FUTURE BACKEND] Replace with: ApiClient.get('/hospitals')
    await Future.delayed(AppDurations.simulatedNetwork);
    return List.from(dummyHospitals);
  }

  Future<HospitalModel?> getHospitalById(String id) async {
    // [FUTURE BACKEND] Replace with: ApiClient.get('/hospitals/$id')
    await Future.delayed(AppDurations.simulatedNetwork);
    try {
      return dummyHospitals.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DoctorModel>> getDoctorsByHospital(String hospitalId) async {
    // [FUTURE BACKEND] Replace with: ApiClient.get('/hospitals/$hospitalId/doctors')
    await Future.delayed(AppDurations.simulatedNetwork);
    return dummyHospitals
        .firstWhere(
          (h) => h.id == hospitalId,
          orElse: () => dummyHospitals.first,
        )
        .doctors;
  }
}
