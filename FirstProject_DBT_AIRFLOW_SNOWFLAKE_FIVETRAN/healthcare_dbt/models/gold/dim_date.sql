WITH source AS (
    SELECT * FROM {{ ref('stg_healthcare') }}
),

dim_date AS (
    SELECT DISTINCT
        visit_date                AS full_date,
        visit_year                AS year,
        visit_month               AS month_number,
        visit_month_name          AS month_name,
        visit_quarter             AS quarter,
        visit_day_name            AS day_of_week
    FROM source
)

SELECT * FROM dim_date