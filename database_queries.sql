-- ============================================================
-- PROJECT: Patient Care Journey Funnel
-- AUTHOR:  Senior Data Analyst Portfolio
-- DESC:    Schema + Mock Data for funnel analysis
-- ============================================================


-- ============================================================
-- TABLE 1: PATIENTS
-- ============================================================
CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    full_name       VARCHAR(100),
    age             INT,
    gender          VARCHAR(10),       -- 'Male', 'Female', 'Other'
    condition       VARCHAR(100),      -- e.g. 'Diabetes', 'Hypertension'
    insurance_type  VARCHAR(50),       -- 'Public', 'Private', 'None'
    registered_at   DATE
);

-- ============================================================
-- TABLE 2: APPOINTMENTS
-- ============================================================
CREATE TABLE appointments (
    appointment_id  SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    appointment_dt  DATE,
    department      VARCHAR(100),      -- e.g. 'Cardiology', 'General'
    status          VARCHAR(20)        -- 'Completed', 'No-show', 'Cancelled'
);

-- ============================================================
-- TABLE 3: DIAGNOSES
-- ============================================================
CREATE TABLE diagnoses (
    diagnosis_id    SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    appointment_id  INT REFERENCES appointments(appointment_id),
    diagnosis_code  VARCHAR(20),       -- ICD-10 style, e.g. 'E11' for Diabetes
    diagnosis_desc  VARCHAR(200),
    diagnosed_at    DATE
);

-- ============================================================
-- TABLE 4: TREATMENTS
-- ============================================================
CREATE TABLE treatments (
    treatment_id    SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    diagnosis_id    INT REFERENCES diagnoses(diagnosis_id),
    treatment_type  VARCHAR(100),      -- 'Medication', 'Surgery', 'Therapy'
    started_at      DATE,
    ended_at        DATE
);

-- ============================================================
-- TABLE 5: FOLLOWUPS
-- ============================================================
CREATE TABLE followups (
    followup_id     SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    treatment_id    INT REFERENCES treatments(treatment_id),
    scheduled_dt    DATE,
    attended        BOOLEAN            -- TRUE = showed up, FALSE = missed
);

-- ============================================================
-- TABLE 6: DISCHARGES
-- ============================================================
CREATE TABLE discharges (
    discharge_id    SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    treatment_id    INT REFERENCES treatments(treatment_id),
    discharged_at   DATE,
    discharge_type  VARCHAR(50)        -- 'Recovered', 'Referred', 'AMA', 'Deceased'
);


-- ============================================================
-- MOCK DATA: PATIENTS (20 records)
-- ============================================================
INSERT INTO patients (full_name, age, gender, condition, insurance_type, registered_at) VALUES
('Alice Johnson',     45, 'Female', 'Diabetes',         'Private', '2024-01-05'),
('Bob Smith',         60, 'Male',   'Hypertension',     'Public',  '2024-01-08'),
('Carol White',       35, 'Female', 'Asthma',           'Private', '2024-01-10'),
('David Brown',       52, 'Male',   'Diabetes',         'None',    '2024-01-12'),
('Eva Martinez',      29, 'Female', 'Anxiety',          'Public',  '2024-01-15'),
('Frank Lee',         67, 'Male',   'Heart Disease',    'Private', '2024-01-18'),
('Grace Kim',         41, 'Female', 'Hypertension',     'Public',  '2024-01-20'),
('Henry Davis',       55, 'Male',   'Diabetes',         'Private', '2024-01-22'),
('Iris Wilson',       38, 'Female', 'Asthma',           'None',    '2024-01-25'),
('James Taylor',      70, 'Male',   'Heart Disease',    'Public',  '2024-01-28'),
('Karen Anderson',    48, 'Female', 'Hypertension',     'Private', '2024-02-01'),
('Leo Thomas',        33, 'Male',   'Anxiety',          'None',    '2024-02-03'),
('Mia Jackson',       57, 'Female', 'Diabetes',         'Public',  '2024-02-05'),
('Nathan Harris',     44, 'Male',   'Heart Disease',    'Private', '2024-02-08'),
('Olivia Martin',     31, 'Female', 'Asthma',           'Public',  '2024-02-10'),
('Paul Garcia',       63, 'Male',   'Hypertension',     'None',    '2024-02-12'),
('Quinn Robinson',    27, 'Female', 'Anxiety',          'Private', '2024-02-15'),
('Ryan Clark',        50, 'Male',   'Diabetes',         'Public',  '2024-02-18'),
('Sophia Lewis',      39, 'Female', 'Heart Disease',    'Private', '2024-02-20'),
('Tom Walker',        58, 'Male',   'Hypertension',     'None',    '2024-02-22');


-- ============================================================
-- MOCK DATA: APPOINTMENTS (not all patients complete — funnel drop-off starts here)
-- ============================================================
INSERT INTO appointments (patient_id, appointment_dt, department, status) VALUES
(1,  '2024-01-10', 'Endocrinology', 'Completed'),
(2,  '2024-01-12', 'Cardiology',    'Completed'),
(3,  '2024-01-15', 'Pulmonology',   'Completed'),
(4,  '2024-01-16', 'Endocrinology', 'No-show'),   -- drops off here
(5,  '2024-01-18', 'Psychiatry',    'Completed'),
(6,  '2024-01-20', 'Cardiology',    'Completed'),
(7,  '2024-01-22', 'Cardiology',    'Completed'),
(8,  '2024-01-25', 'Endocrinology', 'Cancelled'), -- drops off here
(9,  '2024-01-28', 'Pulmonology',   'Completed'),
(10, '2024-01-30', 'Cardiology',    'Completed'),
(11, '2024-02-05', 'Cardiology',    'Completed'),
(12, '2024-02-06', 'Psychiatry',    'Completed'),
(13, '2024-02-08', 'Endocrinology', 'Completed'),
(14, '2024-02-10', 'Cardiology',    'No-show'),   -- drops off here
(15, '2024-02-12', 'Pulmonology',   'Completed'),
(16, '2024-02-14', 'Cardiology',    'Completed'),
(17, '2024-02-16', 'Psychiatry',    'Completed'),
(18, '2024-02-20', 'Endocrinology', 'Completed'),
(19, '2024-02-22', 'Cardiology',    'Completed'),
(20, '2024-02-24', 'Cardiology',    'Cancelled'); -- drops off here


-- ============================================================
-- MOCK DATA: DIAGNOSES (only completed appointments lead to diagnosis)
-- ============================================================
INSERT INTO diagnoses (patient_id, appointment_id, diagnosis_code, diagnosis_desc, diagnosed_at) VALUES
(1,  1,  'E11',  'Type 2 Diabetes Mellitus',         '2024-01-10'),
(2,  2,  'I10',  'Essential Hypertension',            '2024-01-12'),
(3,  3,  'J45',  'Asthma',                            '2024-01-15'),
(5,  5,  'F41',  'Anxiety Disorder',                  '2024-01-18'),
(6,  6,  'I25',  'Chronic Ischemic Heart Disease',    '2024-01-20'),
(7,  7,  'I10',  'Essential Hypertension',            '2024-01-22'),
(9,  9,  'J45',  'Asthma',                            '2024-01-28'),
(10, 10, 'I25',  'Chronic Ischemic Heart Disease',    '2024-01-30'),
(11, 11, 'I10',  'Essential Hypertension',            '2024-02-05'),
(12, 12, 'F41',  'Anxiety Disorder',                  '2024-02-06'),
(13, 13, 'E11',  'Type 2 Diabetes Mellitus',         '2024-02-08'),
(15, 15, 'J45',  'Asthma',                            '2024-02-12'),
(16, 16, 'I10',  'Essential Hypertension',            '2024-02-14'),
(17, 17, 'F41',  'Anxiety Disorder',                  '2024-02-16'),
(18, 18, 'E11',  'Type 2 Diabetes Mellitus',         '2024-02-20'),
(19, 19, 'I25',  'Chronic Ischemic Heart Disease',    '2024-02-22');
-- patients 4, 8, 14, 20 dropped off — no diagnosis


-- ============================================================
-- MOCK DATA: TREATMENTS (some diagnosed patients skip treatment)
-- ============================================================
INSERT INTO treatments (patient_id, diagnosis_id, treatment_type, started_at, ended_at) VALUES
(1,  1,  'Medication',  '2024-01-12', '2024-04-12'),
(2,  2,  'Medication',  '2024-01-14', '2024-04-14'),
(3,  3,  'Therapy',     '2024-01-17', '2024-03-17'),
(5,  4,  'Therapy',     '2024-01-20', '2024-03-20'),
(6,  5,  'Surgery',     '2024-01-25', '2024-02-05'),
(7,  6,  'Medication',  '2024-01-24', '2024-04-24'),
(9,  7,  'Therapy',     '2024-01-30', '2024-03-30'),
(10, 8,  'Medication',  '2024-02-02', '2024-05-02'),
(11, 9,  'Medication',  '2024-02-07', '2024-05-07'),
(13, 11, 'Medication',  '2024-02-10', '2024-05-10'),
(15, 12, 'Therapy',     '2024-02-14', '2024-04-14'),
(16, 13, 'Medication',  '2024-02-16', '2024-05-16'),
(18, 15, 'Medication',  '2024-02-22', '2024-05-22');
-- patients 12, 17, 19 diagnosed but no treatment recorded (drop-off)


-- ============================================================
-- MOCK DATA: FOLLOWUPS (some patients miss follow-ups)
-- ============================================================
INSERT INTO followups (patient_id, treatment_id, scheduled_dt, attended) VALUES
(1,  1,  '2024-02-12', TRUE),
(2,  2,  '2024-02-14', TRUE),
(3,  3,  '2024-02-17', FALSE),  -- missed follow-up
(5,  4,  '2024-02-20', TRUE),
(6,  5,  '2024-02-25', TRUE),
(7,  6,  '2024-02-24', FALSE),  -- missed follow-up
(9,  7,  '2024-03-01', TRUE),
(10, 8,  '2024-03-02', TRUE),
(11, 9,  '2024-03-07', TRUE),
(13, 11, '2024-03-10', FALSE),  -- missed follow-up
(15, 12, '2024-03-14', TRUE),
(16, 13, '2024-03-16', TRUE);
-- patient 18 no follow-up scheduled (drop-off)


-- ============================================================
-- MOCK DATA: DISCHARGES (only patients who completed follow-ups)
-- ============================================================
INSERT INTO discharges (patient_id, treatment_id, discharged_at, discharge_type) VALUES
(1,  1,  '2024-04-12', 'Recovered'),
(2,  2,  '2024-04-14', 'Recovered'),
(5,  4,  '2024-03-20', 'Recovered'),
(6,  5,  '2024-03-05', 'Referred'),
(9,  7,  '2024-03-30', 'Recovered'),
(10, 8,  '2024-05-02', 'Recovered'),
(11, 9,  '2024-05-07', 'Recovered'),
(15, 12, '2024-04-14', 'Recovered'),
(16, 13, '2024-05-16', 'Recovered');
-- several patients did not reach discharge (funnel drop-off)

