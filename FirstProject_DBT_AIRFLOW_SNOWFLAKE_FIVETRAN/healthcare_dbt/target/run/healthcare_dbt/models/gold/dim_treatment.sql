
  
    

create or replace transient table HEALTHCARE_DB.GOLD.dim_treatment
    
    
    
    
    

    as (WITH source AS (
    SELECT * FROM HEALTHCARE_DB.SILVER.stg_healthcare
),

dim_treatment AS (
    SELECT DISTINCT
        treatment_type,
        visit_type
    FROM source
)

SELECT * FROM dim_treatment
    )
;


  