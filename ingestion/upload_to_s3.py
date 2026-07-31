import boto3
import os
from dotenv import load_dotenv

load_dotenv()

AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
BUCKET_NAME = os.getenv("BUCKET_NAME")

def upload_file_to_s3(local_file_path, s3_key):
    s3_client = boto3.client(
        's3',
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY,
        region_name=AWS_REGION
    )
    
    try:
        s3_client.upload_file(local_file_path, BUCKET_NAME, s3_key)
        print(f"Successfully uploaded {local_file_path} to s3://{BUCKET_NAME}/{s3_key}")
    except Exception as e:
        print(f"Upload failed: {e}")


if __name__ == "__main__":
    LOCAL_FILE = "C:/Users/sarth/Downloads/player_season_ipl/cricket_data.csv"  # actual file path
    S3_DESTINATION = "raw/cricket_data/cricket_data.csv"
    
    upload_file_to_s3(LOCAL_FILE, S3_DESTINATION)
