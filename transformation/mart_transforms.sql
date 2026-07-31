-- ============================================
-- MART: Player Career Summary
-- ============================================

USE DATABASE ipl_pipeline;
USE WAREHOUSE ipl_wh;

CREATE OR REPLACE TABLE mart.player_career_summary AS
SELECT
    player_name,
    
    -- Batting career totals
    SUM(matches_batted) AS total_matches_batted,
    SUM(runs_scored) AS total_runs_scored,
    MAX(highest_score) AS career_highest_score,
    SUM(centuries) AS total_centuries,
    SUM(half_centuries) AS total_half_centuries,
    SUM(fours) AS total_fours,
    SUM(sixes) AS total_sixes,
    
    -- Batting average = total runs / total dismissals (matches - not outs)
    ROUND(SUM(runs_scored) / NULLIF(SUM(matches_batted) - SUM(not_outs), 0), 2) AS career_batting_average,
    
    -- Strike rate = (total runs / total balls faced) * 100
    ROUND((SUM(runs_scored) / NULLIF(SUM(balls_faced), 0)) * 100, 2) AS career_strike_rate,
    
    -- Bowling career totals
    SUM(matches_bowled) AS total_matches_bowled,
    SUM(wickets_taken) AS total_wickets_taken,
    SUM(four_wicket_hauls) AS total_four_wicket_hauls,
    SUM(five_wicket_hauls) AS total_five_wicket_hauls,
    
    -- Economy rate = total runs conceded / total overs bowled (balls/6)
    ROUND(SUM(runs_conceded) / NULLIF(SUM(balls_bowled) / 6.0, 0), 2) AS career_economy_rate,
    
    -- Bowling average = total runs conceded / total wickets
    ROUND(SUM(runs_conceded) / NULLIF(SUM(wickets_taken), 0), 2) AS career_bowling_average,
    
    -- Fielding totals
    SUM(catches_taken) AS total_catches,
    SUM(stumpings) AS total_stumpings,
    
    -- Career span
    MIN(year) AS debut_year,
    MAX(year) AS last_played_year,
    COUNT(DISTINCT year) AS seasons_played

FROM staging.player_season_stats
GROUP BY player_name;

SELECT COUNT(*) FROM mart.player_career_summary;

SELECT * FROM mart.player_career_summary 
ORDER BY total_runs_scored DESC 
LIMIT 10;

-- ============================================
-- MART: Year-wise Leaderboard
-- ============================================
CREATE OR REPLACE TABLE mart.year_wise_leaderboard AS

WITH batting_leader AS (
    SELECT 
        year,
        player_name AS top_run_scorer,
        runs_scored AS highest_runs_in_season,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY runs_scored DESC) AS rn
    FROM staging.player_season_stats
),

bowling_leader AS (
    SELECT 
        year,
        player_name AS top_wicket_taker,
        wickets_taken AS highest_wickets_in_season,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY wickets_taken DESC) AS rn
    FROM staging.player_season_stats
)

SELECT 
    b.year,
    b.top_run_scorer,
    b.highest_runs_in_season,
    w.top_wicket_taker,
    w.highest_wickets_in_season
FROM batting_leader b
JOIN bowling_leader w ON b.year = w.year
WHERE b.rn = 1 AND w.rn = 1
ORDER BY b.year DESC;

SELECT * FROM mart.year_wise_leaderboard ORDER BY year DESC;