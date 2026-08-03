from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from datetime import datetime, timedelta
import sys
import os

# Add ingestion folder to path so we can import our upload function
sys.path.append('/opt/airflow/ingestion')

default_args = {
    'owner': 'harsh',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='ipl_data_pipeline',
    default_args=default_args,
    description='End-to-end IPL data pipeline: S3 -> Snowflake RAW -> STAGING -> MART',
    schedule_interval='@daily',
    start_date=datetime(2026, 8, 1),
    catchup=False,
    tags=['ipl', 'data-engineering'],
) as dag:

    def upload_to_s3_task():
        from upload_to_s3 import upload_file_to_s3
        LOCAL_FILE = "/opt/airflow/data/cricket_data.csv"
        S3_DESTINATION = "raw/cricket_data/cricket_data.csv"
        upload_file_to_s3(LOCAL_FILE, S3_DESTINATION)

    task_upload_s3 = PythonOperator(
        task_id='upload_to_s3',
        python_callable=upload_to_s3_task,
    )

    task_load_raw = SnowflakeOperator(
        task_id='load_raw_from_s3',
        snowflake_conn_id='snowflake_default',
        sql="""
            COPY INTO raw.cricket_data
            FROM @ipl_s3_stage/cricket_data.csv
            FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);
        """,
    )

    task_staging = SnowflakeOperator(
        task_id='run_staging_transform',
        snowflake_conn_id='snowflake_default',
        sql='transformation/staging_transforms.sql',
    )

    task_mart = SnowflakeOperator(
        task_id='run_mart_transform',
        snowflake_conn_id='snowflake_default',
        sql='transformation/mart_transforms.sql',
    )

    # Define task dependencies - this is the actual pipeline order
    task_upload_s3 >> task_load_raw >> task_staging >> task_mart