import pandas as pd

FILE_PATH = "C:/Users/sarth/Downloads/player_season_ipl/cricket_data.csv"  # File path on the local device

df = pd.read_csv(FILE_PATH)

# Checking unique values in year column
print("--- Unique Year values ---")
print(df['Year'].unique())

# Finding rows where Year is not a valid number
print("\n--- Rows with bad Year values ---")
bad_rows = df[~df['Year'].astype(str).str.match(r'^\d{4}$')]
print(bad_rows)

# Checking column for duplication issues
print("\n--- Unique Matches_Batted values (sample) ---")
print(df['Matches_Batted'].unique()[:20])