import os
import requests
from zipfile import ZipFile
from io import BytesIO

# List of map URLs from web
map_urls = [
    "https://www.minecraftmaps.com/?task=download.send&id=50204:saturns-orbit&catid=2",
    "https://www.minecraftmaps.com/city?task=download.send&id=42123:bessemer-city&catid=13",
    "https://www.minecraftmaps.com/adventure?task=download.send&id=36166:the-legend-of-the-blue-tide-episode-i-the-myrefall-flats&catid=2"
]

# Directory to save maps
map_dir = "/bedrock_translator/worlds"

# Ensure the directory exists
os.makedirs(map_dir, exist_ok=True)

# Download and extract maps
for url in map_urls:
    response = requests.get(url)
    response.raise_for_status()

    if 'application/zip' in response.headers.get('Content-Type', ''):
        zip_file = ZipFile(BytesIO(response.content))
        map_name = os.path.splitext(os.path.basename(url))[0]
        map_extract_path = os.path.join(map_dir, map_name)
        os.makedirs(map_extract_path, exist_ok=True)
        zip_file.extractall(map_extract_path)
        print(f"Downloaded and extracted {map_name} successfully.")
    else:
        print(f"Skipping {url} as it is not a zip file.")

print("Maps downloaded and extracted successfully.")