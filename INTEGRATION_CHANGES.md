# Frontend-Backend Integration Changes

## Summary
Updated the frontend to work with the actual backend API that fetches data from PostgreSQL database. Removed all mock/dummy data usage from repositories.

## Changes Made

### 1. API Configuration (`core/config/api_config.dart`)
- Removed unused endpoints (auth, hospitals, appointment history/upcoming)
- Updated to match actual backend routes:
  - `/api/patients` - GET all, POST create, GET by id, DELETE
  - `/api/appointments` - GET all, POST create, PATCH status
  - `/api/queue` - GET today's queue, POST create, PATCH status
  - `/api/alerts` - Medical alerts endpoint

### 2. API Service (`core/services/api_service.dart`)
- Added `patch()` method for updating resources
- Added `delete()` method for deleting resources
- Removed `put()` method (backend uses PATCH)

### 3. Appointment Repository (`data/repositories/appointment_repository.dart`)
- **REMOVED**: All dummy data and fallback logic
- **REMOVED**: Local in-memory appointment list
- **UPDATED**: Methods to match backend API:
  - `getAllAppointments()` - Fetches all appointments from backend
  - `createAppointment()` - Creates appointment with patient_id, appointment_date, reason
  - `updateStatus()` - Updates appointment status (scheduled, confirmed, cancelled, completed)
- **REMOVED**: Old methods (getAppointmentHistory, getUpcomingAppointments, bookAppointment, cancelAppointment, rescheduleAppointment)

### 4. Patient Repository (`data/repositories/patient_repository.dart`)
- **REMOVED**: All dummy data and fallback logic
- **REMOVED**: OTP-related methods (sendOtp, verifyOtp)
- **UPDATED**: Methods to match backend API:
  - `getAllPatients()` - Fetches all patients
  - `getPatientById()` - Fetches single patient by ID
  - `createPatient()` - Creates new patient with name, age, gender, phone, address
  - `deletePatient()` - Deletes patient by ID

### 5. Queue Repository (`data/repositories/queue_repository.dart`)
- **REMOVED**: Direct http usage, now uses ApiService
- **ADDED**: New methods:
  - `createQueueEntry()` - Creates queue entry with appointment_id and token_number
  - `updateQueueStatus()` - Updates queue status (waiting, called, completed, skipped)

### 6. Appointment Model (`data/models/appointment_model.dart`)
- **UPDATED**: Structure to match backend database schema:
  - `id` (UUID)
  - `patientId` (UUID reference)
  - `appointmentDate` (DateTime)
  - `reason` (String)
  - `status` (String: scheduled, confirmed, cancelled, completed)
  - `patientName` (Optional, from JOIN query)
- **REMOVED**: Old fields (bookingId, doctorName, hospitalName, specialization, severity, symptoms, tokenNumber)
- **REMOVED**: AppointmentStatus enum and extension

### 7. Patient Model (`data/models/patient_model.dart`)
- **UPDATED**: Structure to match backend database schema:
  - `id` (UUID)
  - `name` (String)
  - `age` (int)
  - `gender` (String: male, female, other)
  - `phone` (String)
  - `address` (String)
- **REMOVED**: Old fields (abhaId, fullName, dateOfBirth, bloodGroup, medicalAlerts, allergies, emergencyContact, emergencyPhone)
- **KEPT**: `initials` getter for UI display

### 8. Queue Model (`data/models/queue_model.dart`)
- Already correctly structured to match backend
- Fields: id, tokenNumber, status, queueDate, patientName, dateOfBirth, gender, appointmentDatetime, reason, doctorName

### 9. Dummy Data (`data/dummy/dummy_data.dart`)
- **REMOVED**: All dummy data content
- File now contains only a comment indicating removal

## Backend API Response Format
All backend responses follow this structure:
```json
{
  "success": true,
  "data": <actual data>,
  "error": null
}
```

## Notes
- Hospital and Doctor models/repositories are kept as-is since they're not yet implemented in the backend
- The frontend now requires the backend to be running at `http://localhost:3000`
- All API calls will throw exceptions if the backend is not available (no fallback to dummy data)

## Next Steps for Full Integration
1. Update UI screens to handle the new model structures
2. Add error handling and loading states in UI
3. Implement hospital/doctor endpoints in backend if needed
4. Add authentication/authorization if required
5. Update booking flow to work with new appointment structure
