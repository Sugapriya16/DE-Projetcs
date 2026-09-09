WITH source AS (
    SELECT * FROM {{ ref('stg_healthcare') }}
),

dim_treatment AS (
    SELECT DISTINCT
        treatment_type,
        visit_type
    FROM source
)

SELECT * FROM dim_treatment