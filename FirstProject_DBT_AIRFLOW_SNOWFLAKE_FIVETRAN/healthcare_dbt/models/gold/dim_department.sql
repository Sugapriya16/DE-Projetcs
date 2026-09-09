WITH source AS (
    SELECT * FROM {{ ref('stg_healthcare') }}
),

dim_department AS (
    SELECT DISTINCT
        department                AS department_name,
        region
    FROM source
)

SELECT * FROM dim_department