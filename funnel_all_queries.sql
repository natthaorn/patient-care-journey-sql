
--- ===============================================
--- 1. Overall Funnel 

SELECT
    '1. Appointment Booked'   AS stage,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM appointments a
WHERE a.status = 'Completed'

UNION ALL

SELECT
    '2. Diagnosis Made',
    COUNT(DISTINCT d.patient_id)
FROM diagnoses d

UNION ALL

SELECT
    '3. Treatment Started',
    COUNT(DISTINCT t.patient_id)
FROM treatments t

UNION ALL

SELECT
    '4. Follow-up Completed',
    COUNT(DISTINCT f.patient_id)
FROM followups f
WHERE f.attended = TRUE

UNION ALL

SELECT
    '5. Discharged',
    COUNT(DISTINCT dis.patient_id)
FROM discharges dis

ORDER BY stage;

--- =====================================================
--- 2. % Drop Rate for each stage

WITH funnel AS (
    SELECT '1. Appointment Booked' AS stage, 1 AS stage_order,
        COUNT(DISTINCT patient_id) AS patient_count
    FROM appointments WHERE status = 'Completed'

    UNION ALL

    SELECT '2. Diagnosis Made', 2,
        COUNT(DISTINCT patient_id)
    FROM diagnoses

    UNION ALL

    SELECT '3. Treatment Started', 3,
        COUNT(DISTINCT patient_id)
    FROM treatments

    UNION ALL

    SELECT '4. Follow-up Completed', 4,
        COUNT(DISTINCT patient_id)
    FROM followups WHERE attended = TRUE

    UNION ALL

    SELECT '5. Discharged', 5,
        COUNT(DISTINCT patient_id)
    FROM discharges
),
funnel_with_prev AS (
    SELECT
        stage,
        stage_order,
        patient_count,
        LAG(patient_count) OVER (ORDER BY stage_order) AS prev_count
    FROM funnel
)
SELECT
    stage,
    patient_count,
    prev_count,
    ROUND(patient_count * 100.0 / FIRST_VALUE(patient_count) 
        OVER (ORDER BY stage_order), 1) AS conversion_from_start_pct,
    CASE 
        WHEN prev_count IS NULL THEN NULL
        ELSE ROUND((prev_count - patient_count) * 100.0 / prev_count, 1)
    END AS dropoff_pct
FROM funnel_with_prev
ORDER BY stage_order;

--- ================================================
--- 3. Funnel Segmentation by Medical Condition 
WITH funnel AS (
    SELECT
        p.condition,
        COUNT(DISTINCT a.patient_id)  AS appointment_count,
        COUNT(DISTINCT d.patient_id)  AS diagnosis_count,
        COUNT(DISTINCT t.patient_id)  AS treatment_count,
        COUNT(DISTINCT CASE WHEN f.attended = TRUE 
            THEN f.patient_id END)    AS followup_count,
        COUNT(DISTINCT dis.patient_id) AS discharge_count
    FROM patients p
    LEFT JOIN appointments  a   ON p.patient_id = a.patient_id 
                                AND a.status = 'Completed'
    LEFT JOIN diagnoses     d   ON p.patient_id = d.patient_id
    LEFT JOIN treatments    t   ON p.patient_id = t.patient_id
    LEFT JOIN followups     f   ON p.patient_id = f.patient_id
    LEFT JOIN discharges    dis ON p.patient_id = dis.patient_id
    GROUP BY p.condition
)
SELECT
    condition,
    appointment_count,
    diagnosis_count,
    treatment_count,
    followup_count,
    discharge_count,
    ROUND(discharge_count * 100.0 / 
        NULLIF(appointment_count, 0), 1) AS end_to_end_conversion_pct
FROM funnel
ORDER BY end_to_end_conversion_pct DESC;

--- ===================================
--- 4. Funnel Segmentation by Insurance Type 
WITH funnel AS (
    SELECT
        p.insurance_type,
        COUNT(DISTINCT a.patient_id) AS appointment_count,
        COUNT(DISTINCT d.patient_id) AS diagnosis_count,
        COUNT(DISTINCT t.patient_id) AS treatment_count,
        COUNT(DISTINCT CASE WHEN f.attended = TRUE THEN f.patient_id END) AS followup_count,
        COUNT(DISTINCT dis.patient_id) AS discharge_count
    FROM patients p
    LEFT JOIN appointments  a   ON p.patient_id = a.patient_id AND a.status = 'Completed'
    LEFT JOIN diagnoses     d   ON p.patient_id = d.patient_id
    LEFT JOIN treatments    t   ON p.patient_id = t.patient_id
    LEFT JOIN followups     f   ON p.patient_id = f.patient_id
    LEFT JOIN discharges    dis ON p.patient_id = dis.patient_id
    GROUP BY p.insurance_type
)
SELECT
    insurance_type,
    appointment_count,
    diagnosis_count,
    treatment_count,
    followup_count,
    discharge_count,
    ROUND(discharge_count * 100.0 / NULLIF(appointment_count, 0), 1) AS end_to_end_conversion_pct
FROM funnel
ORDER BY end_to_end_conversion_pct DESC;
--- =============================================
--- 5. Average Day Between each Stage 
WITH stage_dates AS (
    SELECT
        p.patient_id,
        a.appointment_dt                        AS stage1_dt,
        d.diagnosed_at                          AS stage2_dt,
        t.started_at                            AS stage3_dt,
        f.scheduled_dt                          AS stage4_dt,
        dis.discharged_at                       AS stage5_dt
    FROM patients p
    LEFT JOIN appointments  a   ON p.patient_id = a.patient_id AND a.status = 'Completed'
    LEFT JOIN diagnoses     d   ON p.patient_id = d.patient_id
    LEFT JOIN treatments    t   ON p.patient_id = t.patient_id
    LEFT JOIN followups     f   ON p.patient_id = f.patient_id AND f.attended = TRUE
    LEFT JOIN discharges    dis ON p.patient_id = dis.patient_id
)
SELECT
    ROUND(AVG(stage2_dt - stage1_dt), 1) AS avg_days_appt_to_diagnosis,
    ROUND(AVG(stage3_dt - stage2_dt), 1) AS avg_days_diagnosis_to_treatment,
    ROUND(AVG(stage4_dt - stage3_dt), 1) AS avg_days_treatment_to_followup,
    ROUND(AVG(stage5_dt - stage4_dt), 1) AS avg_days_followup_to_discharge,
    ROUND(AVG(stage5_dt - stage1_dt), 1) AS avg_days_full_journey
FROM stage_dates;