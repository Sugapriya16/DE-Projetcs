WITH source AS (
    SELECT * FROM HEALTHCARE_DB.SILVER.stg_healthcare
),

fact_visits AS (
    SELECT
        -- Keys
        s.patient_id,
        s.visit_date              AS visit_date,

        -- Foreign key references
        p.patient_id              AS patient_fk,
        d.full_date               AS date_fk,
        dp.department_name        AS department_fk,
        t.treatment_type          AS treatment_fk,

        -- Measures
        s.visit_type,
        s.length_of_stay_days,
        s.treatment_cost,
        s.recovery_score,
        s.readmission_risk,
        s.risk_category,
        s.cost_bucket

    FROM source s
    LEFT JOIN HEALTHCARE_DB.GOLD.dim_patient    p  ON s.patient_id    = p.patient_id
    LEFT JOIN HEALTHCARE_DB.GOLD.dim_date       d  ON s.visit_date    = d.full_date
    LEFT JOIN HEALTHCARE_DB.GOLD.dim_department dp ON s.department    = dp.department_name
    LEFT JOIN HEALTHCARE_DB.GOLD.dim_treatment  t  ON s.treatment_type = t.treatment_type
)

SELECT * FROM fact_visits