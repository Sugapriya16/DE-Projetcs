WITH source AS (
    SELECT * FROM {{ ref('stg_healthcare') }}
),

dim_patient AS (
    SELECT DISTINCT
        patient_id,
        age_group,
        gender,
        region,
        risk_category
    FROM source
)

SELECT * FROM dim_patient