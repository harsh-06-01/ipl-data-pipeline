
import pandas as pd

FILE_PATH = "C:/Users/sarth/Downloads/player_season_ipl/cricket_data.csv"

def load_raw_data(filepath):
    df = pd.read_csv(filepath)
    print(f"Loaded {df.shape[0]} rows, {df.shape[1]} columns")
    return df

if __name__ == "__main__":
    df = load_raw_data(FILE_PATH)
    print(df.head())
    