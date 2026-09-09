# 🏥 Healthcare Analytics Pipeline
### City Care Hospital — End-to-End Modern Data Engineering Project

![Pipeline](https://img.shields.io/badge/Pipeline-Medallion%20Architecture-blue)
![Snowflake](https://img.shields.io/badge/Warehouse-Snowflake-29B5E8)
![dbt](https://img.shields.io/badge/Transform-dbt-FF694B)
![Airflow](https://img.shields.io/badge/Orchestrate-Airflow-017CEE)
![Fivetran](https://img.shields.io/badge/Ingest-Fivetran-0073FF)

---

## 📌 Project Overview

An end-to-end modern data engineering pipeline built for **City Care Hospital**
that ingests raw patient visit data, cleans and transforms it using
**Medallion Architecture (Bronze → Silver → Gold)**, and models it into a
**Star Schema** for analytics.

> 💡 **Real-world scenario:** City Care Hospital exports 100+ patient records
> monthly. This pipeline automatically ingests, cleans, and models the data
> so hospital management can answer key business questions.

---

## 🏗️ Architecture

```
Google Sheets → Fivetran → Snowflake (Bronze) → dbt (Silver + Gold) → Airflow
```

```
  📥 INGEST          🥉 BRONZE           🥈 SILVER           🥇 GOLD
  ─────────         ───────────         ───────────         ──────────
  Google Sheets  →  RAW_DATA       →   STG_HEALTHCARE  →   DIM_PATIENT
  (via Fivetran)    (raw landing)       (cleaned &          DIM_DATE
                                        typed data)         DIM_DEPARTMENT
                                                            DIM_TREATMENT
                                                            FACT_VISITS
```

---

## 🛠️ Tech Stack

| Tool | Purpose | Cost |
|------|---------|------|
| **Fivetran** | Data ingestion (Google Sheets → Snowflake) | Free (500K MAR) |
| **Snowflake** | Cloud Data Warehouse | Free ($400 credits) |
| **dbt** | Data transformation + Star Schema modeling | Free (open source) |
| **Apache Airflow** | Pipeline orchestration + scheduling | Free (self-hosted) |
| **Python** | Data generation + scripting | Free |
| **SQL** | Data modeling + analytics | Free |
| **Total Cost** | | **$0** 🎉 |

---

## 📊 Data Model — Star Schema (Gold Layer)

```
                    ┌─────────────────────┐
                    │    FACT_VISITS       │
                    │─────────────────────│
                    │ patient_id (FK) ────┼──→ DIM_PATIENT
                    │ date_id (FK)    ────┼──→ DIM_DATE
                    │ department_id(FK)───┼──→ DIM_DEPARTMENT
                    │ treatment_id(FK)────┼──→ DIM_TREATMENT
                    │ visit_type          │
                    │ length_of_stay_days │
                    │ treatment_cost      │
                    │ recovery_score      │
                    │ readmission_risk    │
                    │ risk_category       │
                    │ cost_bucket         │
                    └─────────────────────┘
```

---

## 📁 Project Structure

```
FirstProject_DBT_AIRFLOW_SNOWFLAKE_FIVETRAN/
├── healthcare_dbt/
│   ├── models/
│   │   ├── silver/
│   │   │   ├── sources.yml
│   │   │   └── stg_healthcare.sql
│   │   └── gold/
│   │       ├── dim_patient.sql
│   │       ├── dim_date.sql
│   │       ├── dim_department.sql
│   │       ├── dim_treatment.sql
│   │       └── fact_visits.sql
│   ├── dbt_project.yml
│   └── profiles.yml
├── dags/
│   └── healthcare_dag.py
├── data/
│   └── healthcare_test_data.txt
└── README.md
```

---

## 📂 Dataset

| Detail | Value |
|--------|-------|
| Format | Pipe-delimited `.txt` |
| Rows | 100 patients |
| Columns | 12 |
| Date Range | 2024 full year |

### Intentional Data Quality Issues
| Issue | Rows affected |
|-------|--------------|
| Missing `treatment_cost` | Every 15th row |
| Missing `recovery_score` | Every 20th row |
| Invalid `gender` value | Every 25th row |

---

## 🥈 Silver Layer — Transformations

| Transformation | Details |
|----------------|---------|
| Data type casting | Dates → DATE, costs → FLOAT |
| Text standardization | UPPER + TRIM on all text columns |
| Null handling | Fill nulls with mean/median |
| Bad value fixing | Invalid gender → 'UNKNOWN' |
| Derived columns | visit_year, visit_month, visit_month_name, quarter |
| Risk categorization | readmission_risk > 0.3 → 'HIGH' else 'LOW' |
| Cost bucketing | LOW / MEDIUM / HIGH / VERY HIGH |

---

## ✈️ Airflow DAG

```python
# Runs on 1st of every month at 6AM
schedule_interval = "0 6 1 * *"

# Task order
check_bronze_data >> dbt_run_silver >> dbt_run_gold >> dbt_test >> pipeline_complete
```

---

## 🔄 How to Run

**1. Clone the repo:**
```bash
git clone https://github.com/YOUR_USERNAME/healthcare-analytics-pipeline.git
cd healthcare-analytics-pipeline
```

**2. Set up Snowflake:**
```sql
CREATE DATABASE HEALTHCARE_DB;
CREATE SCHEMA BRONZE;
CREATE SCHEMA SILVER;
CREATE SCHEMA GOLD;
```

**3. Configure & run dbt:**
```bash
cd healthcare_dbt
dbt debug
dbt run
dbt test
```

**4. Start Airflow:**
```bash
source venv/bin/activate
airflow webserver --port 8080
airflow scheduler
```

**5. Trigger DAG at `http://localhost:8080`**

---

## 📊 Business Questions Answered

```sql
-- 1. Highest treatment cost by department
SELECT department_fk, ROUND(AVG(treatment_cost), 2) AS avg_cost
FROM GOLD.FACT_VISITS GROUP BY 1 ORDER BY 2 DESC;

-- 2. High risk patients by region
SELECT p.region, COUNT(*) AS high_risk_count
FROM GOLD.FACT_VISITS f
JOIN GOLD.DIM_PATIENT p ON f.patient_id = p.patient_id
WHERE f.risk_category = 'HIGH' GROUP BY 1;

-- 3. Monthly revenue trend
SELECT date_fk, ROUND(SUM(treatment_cost), 2) AS revenue
FROM GOLD.FACT_VISITS GROUP BY 1 ORDER BY 1;

-- 4. Recovery score by age group
SELECT p.age_group, ROUND(AVG(f.recovery_score), 2) AS avg_recovery
FROM GOLD.FACT_VISITS f
JOIN GOLD.DIM_PATIENT p ON f.patient_id = p.patient_id
GROUP BY 1 ORDER BY 2 DESC;
```

---

## ✅ Project Checklist

| Task | Status |
|------|--------|
| Snowflake setup (DB + 3 schemas) | ✅ |
| Fivetran Google Sheets connector | ✅ |
| BRONZE.RAW_DATA table | ✅ |
| dbt Silver staging model | ✅ |
| dbt Gold Star Schema (5 tables) | ✅ |
| Airflow DAG (5 tasks) | ✅ |
| Pipeline runs end-to-end | ✅ |
| dbt tests | 🔜 Next project |
| BI Dashboard | 🔜 Next project |

---

## 🎓 What I Learned

- **Fivetran** — Production ingestion without writing ETL code
- **Snowflake** — Cloud data warehouse, schemas, compute sizing
- **dbt** — ref(), source(), staging vs marts layers
- **Airflow** — DAGs, BashOperator, task dependencies, scheduling
- **Star Schema** — Fact vs dimension tables
- **Medallion Architecture** — Bronze/Silver/Gold data layers
- **WSL** — Running Linux tools on Windows

---

*Built as part of Data Engineering learning journey — 2026*  
*Total project cost: $0 🎉*
