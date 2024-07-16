import os
import requests
from zipfile import ZipFile
from io import BytesIO
from amulet.api.wrapper import Translator, World

# List of map URLs from web
map_urls = [
    "https://www.minecraftmaps.com/?task=download.send&id=50204:saturns-orbit&catid=2",
    "https://www.minecraftmaps.com/city?task=download.send&id=42123:bessemer-city&catid=13",
    "https://www.minecraftmaps.com/adventure?task=download.send&id=36166:the-legend-of-the-blue-tide-episode-i-the-myrefall-flats&catid=2"
]

# Directory to save maps
download_dir = "./downloads"
extract_dir = "./extracted"
converted_dir = "/bedrock_translator/worlds"

# Ensure the directories exist
os.makedirs(download_dir, exist_ok=True)
os.makedirs(extract_dir, exist_ok=True)
os.makedirs(converted_dir, exist_ok=True)

# Function to convert maps using Amulet
def convert_map(map_path, output_path):
    world = World(map_path)
    translator = Translator()
    translator.translate(world, output_path)

# Download and extract maps
for url in map_urls:
    try:
        response = requests.get(url)
        response.raise_for_status()

        if 'application/zip' in response.headers.get('Content-Type', ''):
            zip_file = ZipFile(BytesIO(response.content))
            map_name = os.path.splitext(os.path.basename(url))[0]
            map_extract_path = os.path.join(extract_dir, map_name)
            os.makedirs(map_extract_path, exist_ok=True)
            zip_file.extractall(map_extract_path)
            print(f"Downloaded and extracted {map_name} successfully.")

            # Convert the map
            converted_map_path = os.path.join(converted_dir, map_name)
            os.makedirs(converted_map_path, exist_ok=True)
            convert_map(map_extract_path, converted_map_path)
            print(f"Converted {map_name} successfully.")

        else:
            print(f"Skipping {url} as it is not a zip file.")
    except Exception as e:
        print(f"Failed to download or extract {url}. Error: {e}")

print("Maps downloaded, extracted, and converted successfully.")