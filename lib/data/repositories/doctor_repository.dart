import 'package:q_flow/core/config/api_config.dart';
import 'package:q_flow/core/services/api_service.dart';
import 'package:q_flow/data/models/doctor_model.dart';

class DoctorRepository {
  Future<List<DoctorModel>> getAllDoctors() async {
    final response = await ApiService.get(ApiConfig.doctors);
    final List data = response['data'] ?? [];
    return data
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorModel>> getDoctorsBySpecialization(String spec) async {
    final response = await ApiService.get(
      ApiConfig.doctorsBySpecialization(spec),
    );
    final List data = response['data'] ?? [];
    return data
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorModel>> getDoctorsByHospital(String hospitalId) async {
    final response = await ApiService.get(
      ApiConfig.doctorsByHospital(hospitalId),
    );
    final List data = response['data'] ?? [];
    return data
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorModel>> getAvailableDoctorsByHospital(
    String hospitalId,
  ) async {
    final response = await ApiService.get(
      ApiConfig.availableDoctorsByHospital(hospitalId),
    );
    final List data = response['data'] ?? [];
    return data
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
