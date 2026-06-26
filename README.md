# 🏥 Patient Care Journey — Funnel Analysis

A SQL + Tableau portfolio project analyzing patient drop-off across a 5-stage healthcare funnel.

---

## 📌 Project Overview

This project simulates a real-world healthcare analytics scenario where a hospital wants to understand **how patients move through the care journey** — from first appointment to final discharge — and identify where they drop off.

**Domain:** Healthcare  
**Type:** Funnel & Conversion Analysis  
**Tools:** PostgreSQL · DBeaver · Tableau Public  

---

## 🎯 Business Questions Answered

1. How many patients complete each stage of the care journey?
2. Where is the biggest drop-off happening?
3. Which medical conditions have the lowest completion rates?
4. Does insurance type affect how far patients progress?
5. How long does each stage of the journey take on average?

---

## 🗄️ Database Schema

The project uses 6 tables following the patient care funnel:

```
patients → appointments → diagnoses → treatments → followups → discharges
```

| Table | Description | Records |
|---|---|---|
| `patients` | Demographics, condition, insurance type | 20 |
| `appointments` | First contact — department & status | 20 |
| `diagnoses` | ICD-10 coded diagnoses post-appointment | 16 |
| `treatments` | Treatment type and duration | 13 |
| `followups` | Scheduled follow-ups with attendance tracking | 12 |
| `discharges` | Final discharge with outcome type | 9 |

---

## 📊 SQL Queries

### Query 1 — Overall Funnel
Counts distinct patients reaching each stage using `UNION ALL`.

```sql
SELECT '1. Appointment Booked' AS stage, COUNT(DISTINCT patient_id) AS patient_count
FROM appointments WHERE status = 'Completed'
UNION ALL
SELECT '2. Diagnosis Made', COUNT(DISTINCT patient_id) FROM diagnoses
UNION ALL
SELECT '3. Treatment Started', COUNT(DISTINCT patient_id) FROM treatments
UNION ALL
SELECT '4. Follow-up Completed', COUNT(DISTINCT patient_id) FROM followups WHERE attended = TRUE
UNION ALL
SELECT '5. Discharged', COUNT(DISTINCT patient_id) FROM discharges
ORDER BY stage;
```

### Query 2 — Drop-off Rate %
Uses `CTE`, `LAG()`, and `FIRST_VALUE()` to calculate conversion and drop-off at each stage.

### Query 3 — Funnel by Medical Condition
Uses `LEFT JOIN` + `COUNT DISTINCT CASE WHEN` to segment funnel by condition.

### Query 4 — Funnel by Insurance Type
Same structure as Query 3 with `GROUP BY insurance_type` + `NULLIF` to prevent division by zero.

### Query 5 — Average Days Between Stages
Uses date subtraction and `AVG()` to calculate time between each care stage.

> 📁 Full SQL file: [`patient_care_journey_schema.sql`](./patient_care_journey_schema.sql)

---

## 🔍 Key Findings

| Finding | Detail |
|---|---|
| 🔴 Biggest drop-off | Follow-up stage — **30.8%** of patients don't complete it |
| 🟠 Second drop-off | Treatment stage — **18.8%** don't start treatment |
| ✅ Best condition | Hypertension — **75%** end-to-end conversion |
| ⚠️ Worst condition | Diabetes & Anxiety — only **33.3%** complete the journey |
| ⏱️ Longest bottleneck | Follow-up to Discharge — average **44 days** |
| 🏁 Full journey | Average **77 days** from appointment to discharge |

---

## 💡 Recommendations

1. **Improve follow-up attendance** — 30.8% drop-off at this stage is the biggest leak in the funnel. Consider SMS reminders or telehealth follow-up options.
2. **Diabetes patient support** — Only 33.3% of Diabetes patients complete the journey. A dedicated care coordinator program could help.
3. **Reduce discharge delay** — The 44-day gap between follow-up and discharge suggests a process bottleneck worth investigating.
4. **Insurance support program** — Uninsured patients show lower completion rates (note: small sample n=3, needs further validation with larger data).

---

## 📈 Tableau Dashboard

🔗 [View Interactive Dashboard on Tableau Public]([#](https://public.tableau.com/app/profile/natthaorn.lapprasitsuk/viz/Healthcare-FunnelAnalysisDashboard/Dashboard1?publish=yes)) 

(<img width="1443" height="735" alt="Screenshot 2569-06-26 at 11 31 12" src="https://github.com/user-attachments/assets/401ab6ad-e2f0-4fa7-bf2a-2facc7664b91" />

)

**Charts included:**
- Patient Care Journey Funnel Overview
- Drop-off Rate (%) by Stage
- End-to-End Conversion by Medical Condition
- End-to-End Conversion by Insurance Type
- Average Days Between Each Care Stage

---

## ⚠️ Data Notes

- Dataset is **synthetic/mock data** created for portfolio purposes
- 20 patients is a small sample — findings are illustrative, not statistically significant
- Insurance type "None" group has only n=3 patients — interpret with caution
- In a real project, minimum 30+ patients per segment recommended before drawing conclusions

---

## 🛠️ How to Reproduce

1. Install **PostgreSQL** and **DBeaver**
2. Create a database called `patient_funnel_db`
3. Run `patient_care_journey_schema.sql` to create tables and insert data
4. Run each query from the `/queries` folder
5. Export results as CSV and connect to **Tableau Public**

---

## 👤 Author

**[L.Natthaorn]**  
Senior Data Analyst  
📧 [natthaorn.l@gemail.com]  
🔗 ((https://www.linkedin.com/in/natthaornl/))  
🔗 [Tableau Public Profile]((https://public.tableau.com/app/profile/natthaorn.lapprasitsuk/vizzes))  

