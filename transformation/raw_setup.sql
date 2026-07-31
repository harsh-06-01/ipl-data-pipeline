-- Creating a virtual warehouse
CREATE WAREHOUSE IF NOT EXISTS ipl_wh
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Creating the database
CREATE DATABASE IF NOT EXISTS ipl_pipeline;

-- Using the database
USE DATABASE ipl_pipeline;

-- Creating the 3 schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

SHOW SCHEMAS IN DATABASE ipl_pipeline;

USE SCHEMA raw;

CREATE OR REPLACE STAGE ipl_s3_stage
  URL = 's3://ipl-data-pipeline-harsh/raw/cricket_data/'
  CREDENTIALS = (AWS_KEY_ID = '<YOUR_AWS_KEY_ID>' AWS_SECRET_KEY = '<YOUR_AWS_SECRET_KEY>');

  LIST @ipl_s3_stage;

  CREATE OR REPLACE TABLE raw.cricket_data (
    Year STRING,
    Player_Name STRING,
    Matches_Batted STRING,
    Not_Outs STRING,
    Runs_Scored STRING,
    Highest_Score STRING,
    Batting_Average STRING,
    Balls_Faced STRING,
    Batting_Strike_Rate STRING,
    Centuries STRING,
    Half_Centuries STRING,
    Fours STRING,
    Sixes STRING,
    Catches_Taken STRING,
    Stumpings STRING,
    Matches_Bowled STRING,
    Balls_Bowled STRING,
    Runs_Conceded STRING,
    Wickets_Taken STRING,
    Best_Bowling_Match STRING,
    Bowling_Average STRING,
    Economy_Rate STRING,
    Bowling_Strike_Rate STRING,
    Four_Wicket_Hauls STRING,
    Five_Wicket_Hauls STRING
);

COPY INTO raw.cricket_data
FROM @ipl_s3_stage/cricket_data.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);

SELECT COUNT(*) FROM raw.cricket_data;

SELECT * FROM raw.cricket_data LIMIT 10;