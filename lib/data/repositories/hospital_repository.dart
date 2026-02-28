import 'package:q_flow/data/models/hospital_model.dart';
import 'package:q_flow/data/dummy/real_hospitals.dart';

class HospitalRepository {
  Future<List<HospitalModel>> getNearbyHospitals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return realHospitals;
  }

  Future<HospitalModel?> getHospitalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return realHospitals.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<HospitalDoctorModel>> getDoctorsByHospital(
    String hospitalId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return realHospitals.firstWhere((h) => h.id == hospitalId).doctors;
    } catch (_) {
      return [];
    }
  }
}
