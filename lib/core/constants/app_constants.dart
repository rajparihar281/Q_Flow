class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 100;
}

class AppStrings {
  AppStrings._();

  static const appName = 'Q-Flow';
  static const appTagline = 'Hospital Smart Queue';
  static const poweredBy = 'Powered by ABHA';

  // Privacy
  static const privacyNote =
      'Your health data is processed securely and never shared without your consent.';
  static const consentNotice =
      'By using Q-Flow, you consent to the use of anonymized data solely for healthcare optimization.';
  static const disclaimer =
      'Q-Flow provides queue and appointment management only. Always consult a licensed medical professional for diagnosis and treatment.';

  // Booking
  static const bookingSuccess = 'Appointment Booked!';
  static const bookingSubtitle = 'Your token has been generated.';

  // Error / Empty
  static const errorGeneric = 'Something went wrong. Please try again.';
  static const emptyAppointments = 'No appointments found.';
  static const emptyDoctors = 'No doctors available right now.';
  static const emptyHospitals = 'No hospitals found nearby.';
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration page = Duration(milliseconds: 350);
  static const Duration simulatedNetwork = Duration(milliseconds: 800);
  static const Duration queueRefresh = Duration(seconds: 8);
}
