import os
import requests
from zipfile import ZipFile
from io import BytesIO
import tarfile

# List of map URLs from web
map_urls = [
    "https://www.minecraftmaps.com/?task=download.send&id=50204:saturns-orbit&catid=2",
    "https://www.minecraftmaps.com/city?task=download.send&id=42123:bessemer-city&catid=13",
    "https://www.minecraftmaps.com/adventure?task=download.send&id=36166:the-legend-of-the-blue-tide-episode-i-the-myrefall-flats&catid=2"
]

# Directory to save maps
map_dir = "/maps"

# Ensure the directory exists and has correct permissions
os.makedirs(map_dir, exist_ok=True)
os.chmod(map_dir, 0o777)

# Function to extract ZIP files
def extract_zip(zip_content, extract_path):
    with ZipFile(BytesIO(zip_content)) as zip_ref:
        zip_ref.extractall(extract_path)

# Function to extract JAR files (treated as ZIP for simplicity)
def extract_jar(jar_content, extract_path):
    extract_zip(jar_content, extract_path)

# Function to extract TAR files
def extract_tar(tar_content, extract_path):
    with tarfile.open(fileobj=BytesIO(tar_content)) as tar_ref:
        tar_ref.extractall(extract_path)

# Download and extract maps
for url in map_urls:
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check for HTTP request errors

        content_type = response.headers.get('Content-Type', '')
        file_extension = os.path.splitext(url)[1]

        map_name = os.path.splitext(os.path.basename(url))[0]
        map_extract_path = os.path.join(map_dir, map_name)

        # Save and extract the file based on type
        if 'application/zip' in content_type or file_extension == '.zip':
            extract_zip(response.content, map_extract_path)
        elif 'application/java-archive' in content_type or file_extension == '.jar':
            extract_jar(response.content, map_extract_path)
        elif 'application/x-tar' in content_type or file_extension == '.tar':
            extract_tar(response.content, map_extract_path)
        else:
            print(f"Skipping {url} as it is not a supported archive file.")
            continue

        print(f"Downloaded and extracted {map_name} successfully.")

    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")

print("Maps downloaded and extracted successfully.")