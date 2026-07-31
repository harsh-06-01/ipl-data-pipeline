USE DATABASE ipl_pipeline;
USE WAREHOUSE ipl_wh;

CREATE OR REPLACE TABLE staging.player_season_stats AS
SELECT
    TRY_CAST(Year AS INT) AS year,
    Player_Name AS player_name,
    TRY_CAST(Matches_Batted AS INT) AS matches_batted,
    TRY_CAST(Not_Outs AS INT) AS not_outs,
    TRY_CAST(Runs_Scored AS INT) AS runs_scored,
    
    CASE WHEN Highest_Score LIKE '%*%' THEN TRUE ELSE FALSE END AS highest_score_not_out,
    TRY_CAST(REPLACE(Highest_Score, '*', '') AS INT) AS highest_score,
    
    TRY_CAST(Batting_Average AS FLOAT) AS batting_average,
    TRY_CAST(Balls_Faced AS INT) AS balls_faced,
    TRY_CAST(Batting_Strike_Rate AS FLOAT) AS batting_strike_rate,
    TRY_CAST(Centuries AS INT) AS centuries,
    TRY_CAST(Half_Centuries AS INT) AS half_centuries,
    TRY_CAST(Fours AS INT) AS fours,
    TRY_CAST(Sixes AS INT) AS sixes,
    TRY_CAST(Catches_Taken AS INT) AS catches_taken,
    TRY_CAST(Stumpings AS INT) AS stumpings,
    TRY_CAST(Matches_Bowled AS INT) AS matches_bowled,
    TRY_CAST(Balls_Bowled AS INT) AS balls_bowled,
    TRY_CAST(Runs_Conceded AS INT) AS runs_conceded,
    TRY_CAST(Wickets_Taken AS INT) AS wickets_taken,
    
    TRY_CAST(SPLIT_PART(Best_Bowling_Match, '/', 1) AS INT) AS best_bowling_wickets,
    TRY_CAST(SPLIT_PART(Best_Bowling_Match, '/', 2) AS INT) AS best_bowling_runs,
    
    TRY_CAST(Bowling_Average AS FLOAT) AS bowling_average,
    TRY_CAST(Economy_Rate AS FLOAT) AS economy_rate,
    TRY_CAST(Bowling_Strike_Rate AS FLOAT) AS bowling_strike_rate,
    TRY_CAST(Four_Wicket_Hauls AS INT) AS four_wicket_hauls,
    TRY_CAST(Five_Wicket_Hauls AS INT) AS five_wicket_hauls

FROM raw.cricket_data
WHERE Year != 'No stats';

SELECT COUNT(*) FROM staging.player_season_stats;

SELECT * FROM staging.player_season_stats LIMIT 10;
