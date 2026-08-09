# IPL Data Analytics Pipeline

An end-to-end data engineering pipeline that ingests IPL (Indian Premier League) player statistics, transforms them through a 3-layer warehouse architecture, and serves the results through an interactive dashboard — orchestrated entirely by Apache Airflow.

**[View Live Dashboard →](https://datastudio.google.com/reporting/b697f9c0-925a-4be6-b60c-51044ba01a49)**

---

## Overview

This project simulates a real-world data engineering workflow: raw data lands in cloud storage, gets loaded into a cloud data warehouse, is cleaned and modeled through progressive layers, and is finally exposed to business users through a self-serve dashboard — all automated on a schedule.

I built this to apply data engineering fundamentals (SQL, Python, cloud data warehousing, and orchestration) to a real dataset, and to work through the kinds of infrastructure and debugging challenges that come up in production pipelines rather than a tutorial-perfect setup.

---

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌───────────────────┐
│  Kaggle Dataset  │────▶│   AWS S3     │────▶│  Snowflake (RAW)   │
│  (cricket_data)  │     │ raw/cricket  │     │  raw.cricket_data  │
└─────────────────┘     └──────────────┘     └────────┬───────────┘
                                                        │
                                                        ▼
                                              ┌───────────────────┐
                                              │ Snowflake (STAGING)│
                                              │  Cleaned & typed   │
                                              └────────┬───────────┘
                                                        │
                                                        ▼
                                              ┌───────────────────┐
                                              │  Snowflake (MART)  │
                                              │  3 analytics tables│
                                              └────────┬───────────┘
                                                        │
                                                        ▼
                                              ┌───────────────────┐
                                              │   Looker Studio    │
                                              │   3-page dashboard │
                                              └───────────────────┘

        Orchestrated end-to-end by Apache Airflow (Docker)
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Ingestion | Python, boto3 |
| Storage (raw) | AWS S3 |
| Data Warehouse | Snowflake |
| Transformation | SQL (Snowflake) |
| Orchestration | Apache Airflow (Docker) |
| Visualization | Looker Studio |
| Version Control | Git / GitHub |

---

## Data Warehouse Design

The pipeline follows a standard 3-layer warehouse pattern:

- **RAW** — exact copy of the source data, untouched, including messy/invalid rows
- **STAGING** — cleaned, properly typed data with defensive SQL (`TRY_CAST`, `NULLIF`) to handle bad values without failing
- **MART** — business-ready analytical tables, built for direct dashboard consumption

### MART Tables

| Table | Description |
|---|---|
| `player_career_summary` | Career-level aggregated batting/bowling stats per player |
| `year_wise_leaderboard` | Top run-scorer and top wicket-taker per IPL season (built using window functions) |
| `all_rounder_rankings` | Custom-weighted score combining batting and bowling contribution to rank all-rounders |

---

## Pipeline Orchestration

A single Airflow DAG (`ipl_data_pipeline`) automates the full flow:

```
upload_to_s3  →  load_raw_from_s3  →  run_staging_transform  →  run_mart_transform
```

Each task depends on the previous one succeeding, and the whole pipeline is scheduled to run automatically. The Airflow environment runs fully containerized via Docker Compose.

---

## Key Engineering Decisions

**Why a 3-layer warehouse instead of transforming data on load?**
Keeping RAW untouched means any transformation bug can be fixed and re-run without re-ingesting data. It also makes debugging easier since each layer's output can be inspected independently.

**Why SQL for cleaning instead of Python?**
Since the data ultimately lives in Snowflake, using SQL (with `TRY_CAST` and `NULLIF` for defensive handling of bad values) keeps the transformation logic close to the data and avoids unnecessary round-trips between Python and the warehouse.

**Why switch from Cricsheet's raw ball-by-ball files to a pre-aggregated dataset?**
I initially attempted to parse Cricsheet's raw match-by-match files directly, but the nested registry format required significant custom parsing logic for limited additional value. I made the call to use a well-maintained, pre-aggregated season-stats dataset instead, prioritizing time spent on pipeline infrastructure over data parsing edge cases.

**Why LocalExecutor instead of CeleryExecutor for Airflow?**
CeleryExecutor requires a separate worker and Redis broker, which added complexity and reliability issues in a local Docker Desktop environment. LocalExecutor runs tasks directly via the scheduler — simpler, lighter, and more reliable for a single-machine setup, while still demonstrating real DAG-based orchestration.

---

## Notable Challenges Solved

- Diagnosed and fixed a Snowflake SSL hostname mismatch caused by an incorrectly formatted account identifier
- Resolved a silent Celery task-handoff failure by switching Airflow's executor model
- Debugged a missing Snowflake stage by cross-referencing Airflow's CLI test output against Snowflake's own query history
- Fixed Airflow's Jinja template resolution for SQL file paths using `template_searchpath`
- Secured AWS credentials using `.env` + `.gitignore`, keeping secrets out of version control throughout

---

## Project Structure

```
ipl-data-pipeline/
├── dags/
│   └── ipl_pipeline_dag.py       # Airflow DAG definition
├── ingestion/
│   └── upload_to_s3.py           # Uploads raw CSV to S3
├── transformation/
│   ├── raw_setup.sql             # Warehouse, database, schema, stage setup
│   ├── staging_transforms.sql    # RAW → STAGING cleaning logic
│   └── mart_transforms.sql       # STAGING → MART analytical tables
├── data_quality/
│   └── quality_checks.py         # (planned) data validation checks
├── dashboard/
│   └── screenshots/              # Dashboard preview images
├── docker-compose.yaml           # Airflow environment (Docker)
├── Dockerfile                    # Custom Airflow image with Snowflake provider
├── requirements.txt
└── README.md
```

---

## Dashboard Preview

The dashboard has 3 pages:

1. **Career Leaders** — All-time top run scorers and wicket takers
2. **Season Leaderboard** — Year-by-year top performers with a scoring trend line
3. **All-Rounders** — Combined batting/bowling ranking with a batting vs. bowling scatter plot

**[View Live Dashboard →](https://datastudio.google.com/reporting/b697f9c0-925a-4be6-b60c-51044ba01a49)**

---

## What I'd Add With More Time

- Automated data quality checks as a dedicated Airflow DAG (schema validation, null checks, referential integrity)
- Incremental loading instead of full-table reloads
- IAM role-based Snowflake storage integration instead of static AWS credentials
- CI/CD for SQL transformation testing

---

## About

Built as a hands-on project to apply data engineering fundamentals — SQL, cloud data warehousing, pipeline orchestration, and infrastructure debugging — to a real, end-to-end pipeline.
