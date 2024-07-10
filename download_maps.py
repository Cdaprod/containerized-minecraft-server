import os
import requests
from zipfile import ZipFile

# List of map URLs
map_urls = [
    "https://www.minecraftmaps.com/49730-be-boxed/download",
    "https://www.minecraftmaps.com/49724-clean-choices/download",
    "https://www.minecraftmaps.com/50204-saturns-orbit/download",
    "https://www.minecraftmaps.com/49985-evergrowth/download",
    "https://www.minecraftmaps.com/36166-the-legend-of-the-blue-tide-episode-i-the-myrefall-flats/download"
]

# Directory to save maps
map_dir = "/var/games/minecraft/servers"

# Ensure the directory exists
os.makedirs(map_dir, exist_ok=True)

# Download and extract maps
for url in map_urls:
    response = requests.get(url)
    zip_path = os.path.join(map_dir, os.path.basename(url) + ".zip")
    
    # Save the zip file
    with open(zip_path, "wb") as f:
        f.write(response.content)
    
    # Extract the zip file
    with ZipFile(zip_path, 'r') as zip_ref:
        map_name = os.path.splitext(os.path.basename(zip_path))[0]
        map_extract_path = os.path.join(map_dir, map_name)
        zip_ref.extractall(map_extract_path)
    
    # Remove the zip file
    os.remove(zip_path)
    
print("Maps downloaded and extracted successfully.")