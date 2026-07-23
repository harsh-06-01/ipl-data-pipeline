import pandas as pd

FILE_PATH = "C:/Users/sarth/Downloads/player_season_ipl/cricket_data.csv"  # use your correct path

df = pd.read_csv(FILE_PATH)

# Check unique values in Year column - look for non-numeric junk
print("--- Unique Year values ---")
print(df['Year'].unique())

# Find rows where Year is not a valid number
print("\n--- Rows with bad Year values ---")
bad_rows = df[~df['Year'].astype(str).str.match(r'^\d{4}$')]
print(bad_rows)

# Check a few other columns for similar issues
print("\n--- Unique Matches_Batted values (sample) ---")
print(df['Matches_Batted'].unique()[:20])