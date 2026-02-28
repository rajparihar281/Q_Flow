import 'package:flutter/foundation.dart';

class ApiConfig {
  // ─── Base URLs ───────────────────────────────────────────────────────────────
  // Automatically use localhost for Web, and machine IP for physical devices/emulators
  static const String _host = kIsWeb ? 'localhost' : '10.100.49.11';
  static const int _port = 3000;
  static const String baseUrl = 'http://$_host:$_port/api';
  static const String wsUrl = 'ws://$_host:$_port/ws/queue';

  // ─── Patients ────────────────────────────────────────────────────────────────
  static const String patients = '$baseUrl/patients';
  static String patientById(String id) => '$baseUrl/patients/$id';
  static String patientByAbha(String abhaId) =>
      '$baseUrl/patients/abha/$abhaId';

  // ─── Doctors ─────────────────────────────────────────────────────────────────
  static const String doctors = '$baseUrl/doctors';
  static String doctorById(String id) => '$baseUrl/doctors/$id';
  static String doctorsBySpecialization(String spec) =>
      '$baseUrl/doctors?specialization=$spec';
  static String doctorsByHospital(String hospitalId) =>
      '$baseUrl/doctors/hospital/$hospitalId';
  static String availableDoctorsByHospital(String hospitalId) =>
      '$baseUrl/doctors/hospital/$hospitalId?available=true';

  // ─── Appointments ────────────────────────────────────────────────────────────
  static const String appointments = '$baseUrl/appointments';
  static String appointmentById(String id) => '$baseUrl/appointments/$id';
  static String appointmentsByPatient(String patientId) =>
      '$baseUrl/appointments?patientId=$patientId';
  static String appointmentStatus(String id) =>
      '$baseUrl/appointments/$id/status';

  // ─── Queue ───────────────────────────────────────────────────────────────────
  static const String queueToday = '$baseUrl/queue/today';
  static String queueStatus(String id) => '$baseUrl/queue/$id/status';
  static String queueByDoctor(String doctorId) =>
      '$baseUrl/queue/doctor/$doctorId';

  // ─── Alerts ──────────────────────────────────────────────────────────────────
  static String alertsByPatient(String patientId) =>
      '$baseUrl/alerts/$patientId';

  // ─── Health ──────────────────────────────────────────────────────────────────
  static String get health => 'http://$_host:$_port/health';
}
