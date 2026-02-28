-- ============================================================================
-- Q-FLOW HOSPITAL QUEUE SYSTEM - DATABASE SCHEMA
-- ============================================================================
-- Version: 1.0
-- Database: PostgreSQL / MySQL Compatible
-- Purpose: Hospital appointment booking and queue management system
-- ============================================================================

-- ============================================================================
-- 1. PATIENTS TABLE
-- ============================================================================
CREATE TABLE patients (
    id VARCHAR(50) PRIMARY KEY,
    abha_id VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    blood_group VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    emergency_contact VARCHAR(200),
    emergency_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_abha_id (abha_id),
    INDEX idx_phone (phone)
);

-- ============================================================================
-- 2. PATIENT MEDICAL ALERTS TABLE
-- ============================================================================
CREATE TABLE patient_medical_alerts (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    alert_type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id)
);

-- ============================================================================
-- 3. PATIENT ALLERGIES TABLE
-- ============================================================================
CREATE TABLE patient_allergies (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    allergy VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id)
);

-- ============================================================================
-- 4. HOSPITALS TABLE
-- ============================================================================
CREATE TABLE hospitals (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    rating DECIMAL(2, 1) DEFAULT 0.0,
    specialities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_location (latitude, longitude)
);

-- ============================================================================
-- 5. DOCTORS TABLE
-- ============================================================================
CREATE TABLE doctors (
    id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    experience_years INT NOT NULL,
    rating DECIMAL(2, 1) DEFAULT 0.0,
    available_today BOOLEAN DEFAULT TRUE,
    availability_status VARCHAR(50) DEFAULT 'Available Today',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_specialization (specialization),
    INDEX idx_available (available_today)
);

-- ============================================================================
-- 6. APPOINTMENTS TABLE
-- ============================================================================
CREATE TABLE appointments (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50) UNIQUE NOT NULL,
    patient_id VARCHAR(50) NOT NULL,
    doctor_id VARCHAR(50) NOT NULL,
    hospital_id VARCHAR(50) NOT NULL,
    appointment_date_time TIMESTAMP NOT NULL,
    severity VARCHAR(20) NOT NULL,
    symptoms TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'upcoming',
    token_number INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    INDEX idx_patient_id (patient_id),
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_status (status),
    INDEX idx_appointment_date (appointment_date_time),
    INDEX idx_booking_id (booking_id),
    CHECK (status IN ('upcoming', 'completed', 'cancelled')),
    CHECK (severity IN ('Low', 'Medium', 'High'))
);

-- ============================================================================
-- 7. OTP VERIFICATION TABLE
-- ============================================================================
CREATE TABLE otp_verifications (
    id SERIAL PRIMARY KEY,
    abha_id VARCHAR(100) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_abha_id (abha_id),
    INDEX idx_expires_at (expires_at)
);

-- ============================================================================
-- 8. QUEUE MANAGEMENT TABLE
-- ============================================================================
CREATE TABLE queue_entries (
    id SERIAL PRIMARY KEY,
    appointment_id VARCHAR(50) NOT NULL,
    doctor_id VARCHAR(50) NOT NULL,
    hospital_id VARCHAR(50) NOT NULL,
    token_number INT NOT NULL,
    queue_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'waiting',
    called_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    INDEX idx_appointment_id (appointment_id),
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_queue_date (queue_date),
    INDEX idx_status (status),
    CHECK (status IN ('waiting', 'called', 'completed', 'skipped'))
);

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================

-- Insert sample patient
INSERT INTO patients (id, abha_id, full_name, date_of_birth, gender, blood_group, phone, address, emergency_contact, emergency_phone)
VALUES ('p001', 'PMJAY-MH-2024-887654', 'Ramesh Kumar', '1978-03-14', 'Male', 'B+', '+91-98765-43210', 
        '47 Shivaji Nagar, Pune, Maharashtra 411005', 'Sunita Kumar (Wife)', '+91-98123-45678');

-- Insert patient medical alerts
INSERT INTO patient_medical_alerts (patient_id, alert_type) VALUES 
('p001', 'Type 2 Diabetes'),
('p001', 'Hypertension');

-- Insert patient allergies
INSERT INTO patient_allergies (patient_id, allergy) VALUES 
('p001', 'Penicillin'),
('p001', 'Sulfa Drugs');

-- Insert sample hospitals
INSERT INTO hospitals (id, name, address, phone, rating, specialities) VALUES
('h1', 'City Care Hospital', '12 MG Road, Pune, Maharashtra 411001', '+91-20-6678-9000', 4.6, 'Cardiology, Ortho'),
('h2', 'Apollo Clinic', 'Survey No. 21, Baner, Pune 411045', '+91-20-3940-4000', 4.8, 'Neurology, ENT'),
('h3', 'Metro Health Center', 'Plot 5, Kothrud, Pune 411038', '+91-20-2545-1100', 4.4, 'General Medicine, Pediatrics');

-- Insert sample doctors
INSERT INTO doctors (id, hospital_id, name, specialization, experience_years, rating, available_today, availability_status) VALUES
('d1', 'h1', 'Dr. Anil Sharma', 'Cardiology', 14, 4.8, TRUE, 'Available Today'),
('d2', 'h1', 'Dr. Priya Kapoor', 'Orthopedic', 9, 4.5, FALSE, 'Limited Slots'),
('d3', 'h2', 'Dr. Rahul Mehta', 'Neurology', 12, 4.9, TRUE, 'Available Today'),
('d4', 'h2', 'Dr. Sneha Bose', 'ENT', 7, 4.6, TRUE, 'Available Today'),
('d5', 'h3', 'Dr. Deepak Iyer', 'General Medicine', 8, 4.9, FALSE, 'Limited Slots');

-- Insert sample appointments
INSERT INTO appointments (id, booking_id, patient_id, doctor_id, hospital_id, appointment_date_time, severity, symptoms, status, token_number) VALUES
('a001', 'QF-20240115-4821', 'p001', 'd1', 'h1', '2024-01-15 10:00:00', 'Medium', 'Occasional chest discomfort, mild breathlessness', 'completed', 23),
('a002', 'QF-20240209-3310', 'p001', 'd5', 'h3', '2024-02-09 09:30:00', 'Low', 'Seasonal flu, mild fever', 'completed', 11),
('a003', 'QF-20240318-7722', 'p001', 'd3', 'h2', '2024-03-18 11:00:00', 'High', 'Persistent headaches, blurred vision', 'cancelled', 47);

-- ============================================================================
-- USEFUL QUERIES
-- ============================================================================

-- Get patient with all details
-- SELECT p.*, 
--        GROUP_CONCAT(DISTINCT pma.alert_type) as medical_alerts,
--        GROUP_CONCAT(DISTINCT pa.allergy) as allergies
-- FROM patients p
-- LEFT JOIN patient_medical_alerts pma ON p.id = pma.patient_id
-- LEFT JOIN patient_allergies pa ON p.id = pa.patient_id
-- WHERE p.abha_id = 'PMJAY-MH-2024-887654'
-- GROUP BY p.id;

-- Get upcoming appointments for a patient
-- SELECT a.*, d.name as doctor_name, h.name as hospital_name, d.specialization
-- FROM appointments a
-- JOIN doctors d ON a.doctor_id = d.id
-- JOIN hospitals h ON a.hospital_id = h.id
-- WHERE a.patient_id = 'p001' 
-- AND a.status = 'upcoming'
-- AND a.appointment_date_time > NOW()
-- ORDER BY a.appointment_date_time ASC;

-- Get appointment history for a patient
-- SELECT a.*, d.name as doctor_name, h.name as hospital_name, d.specialization
-- FROM appointments a
-- JOIN doctors d ON a.doctor_id = d.id
-- JOIN hospitals h ON a.hospital_id = h.id
-- WHERE a.patient_id = 'p001'
-- ORDER BY a.appointment_date_time DESC;

-- Get available doctors at a hospital
-- SELECT d.*, h.name as hospital_name
-- FROM doctors d
-- JOIN hospitals h ON d.hospital_id = h.id
-- WHERE d.hospital_id = 'h1' AND d.available_today = TRUE;

-- Get queue status for a doctor on a specific date
-- SELECT q.*, a.booking_id, p.full_name as patient_name
-- FROM queue_entries q
-- JOIN appointments a ON q.appointment_id = a.id
-- JOIN patients p ON a.patient_id = p.id
-- WHERE q.doctor_id = 'd1' 
-- AND q.queue_date = CURRENT_DATE
-- ORDER BY q.token_number ASC;
