WITH source AS (
    SELECT * FROM {{ source('bronze', 'RAW_DATA') }}
),

cleaned AS (
    SELECT
        -- IDs
        CAST(patient_id AS INT)                        AS patient_id,

        -- Dates
        CAST(visit_date AS DATE)                       AS visit_date,
        YEAR(CAST(visit_date AS DATE))                 AS visit_year,
        MONTH(CAST(visit_date AS DATE))                AS visit_month,
        MONTHNAME(CAST(visit_date AS DATE))            AS visit_month_name,
        QUARTER(CAST(visit_date AS DATE))              AS visit_quarter,
        DAYNAME(CAST(visit_date AS DATE))              AS visit_day_name,

        -- Clean text columns
        UPPER(TRIM(age_group))                         AS age_group,
        CASE
            WHEN UPPER(TRIM(gender)) NOT IN ('MALE','FEMALE')
            THEN 'UNKNOWN'
            ELSE UPPER(TRIM(gender))
        END                                            AS gender,
        UPPER(TRIM(region))                            AS region,
        UPPER(TRIM(department))                        AS department,
        UPPER(TRIM(treatment_type))                    AS treatment_type,
        UPPER(TRIM(visit_type))                        AS visit_type,

        -- Numeric columns
        ROUND(COALESCE(
            TRY_CAST(length_of_stay_days AS FLOAT), 0), 2)
                                                       AS length_of_stay_days,
        ROUND(COALESCE(
            TRY_CAST(treatment_cost AS FLOAT),
            AVG(TRY_CAST(treatment_cost AS FLOAT))
                OVER()), 2)                            AS treatment_cost,
        ROUND(COALESCE(
            TRY_CAST(recovery_score AS FLOAT),
            MEDIAN(TRY_CAST(recovery_score AS FLOAT))
                OVER()), 2)                            AS recovery_score,
        ROUND(COALESCE(
            TRY_CAST(readmission_risk AS FLOAT), 0), 2)
                                                       AS readmission_risk,

        -- Derived columns
        CASE
            WHEN TRY_CAST(readmission_risk AS FLOAT) > 0.3
            THEN 'HIGH'
            ELSE 'LOW'
        END                                            AS risk_category,

        CASE
            WHEN TRY_CAST(treatment_cost AS FLOAT) < 20000  THEN 'LOW'
            WHEN TRY_CAST(treatment_cost AS FLOAT) < 50000  THEN 'MEDIUM'
            WHEN TRY_CAST(treatment_cost AS FLOAT) < 100000 THEN 'HIGH'
            ELSE 'VERY HIGH'
        END                                            AS cost_bucket

    FROM source
    WHERE patient_id IS NOT NULL
)

SELECT * FROM cleaned