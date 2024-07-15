import os
import requests
from zipfile import ZipFile
from io import BytesIO

# List of map URLs from web
map_urls = [
    "https://www.minecraftmaps.com/49730-be-boxed/download",
    "https://www.minecraftmaps.com/49724-clean-choices/download",
    "https://www.minecraftmaps.com/50204-saturns-orbit/download",
    "https://www.minecraftmaps.com/49985-evergrowth/download",
    "https://www.minecraftmaps.com/36166-the-legend-of-the-blue-tide-episode-i-the-myrefall-flats/download"
]

# Directory to save maps
map_dir = "/maps"

# Ensure the directory exists
os.makedirs(map_dir, exist_ok=True)

# Download and extract maps
for url in map_urls:
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check for HTTP request errors

        if 'Content-Type' not in response.headers or response.headers['Content-Type'] != 'application/zip':
            print(f"Skipping {url} as it is not a zip file.")
            continue

        map_name = os.path.splitext(os.path.basename(url))[0]
        map_extract_path = os.path.join(map_dir, map_name)

        # Save and extract the zip file
        with ZipFile(BytesIO(response.content)) as zip_ref:
            zip_ref.extractall(map_extract_path)

        print(f"Downloaded and extracted {map_name} successfully.")
        
    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")

print("Maps downloaded and extracted successfully.")