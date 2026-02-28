class SessionManager {
  static String? _patientId;

  static void setPatientId(String id) {
    _patientId = id;
  }

  static String? getPatientId() {
    return _patientId;
  }

  static void clear() {
    _patientId = null;
  }
}
