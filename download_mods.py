import os
import requests
from zipfile import ZipFile
from io import BytesIO

# List of mod URLs from web
mod_urls = [
    "https://www.curseforge.com/minecraft/modpacks/minecraft-but-better-mbb/download/3385490"
    # Add other URLs as needed
]

# Directory to save mods
mod_dir = "/mods"

# Ensure the directory exists and has correct permissions
os.makedirs(mod_dir, exist_ok=True)
os.chmod(mod_dir, 0o777)

# Function to extract ZIP files
def extract_zip(zip_content, extract_path):
    with ZipFile(BytesIO(zip_content)) as zip_ref:
        zip_ref.extractall(extract_path)

# Download and extract mods
for url in mod_urls:
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check for HTTP request errors

        content_type = response.headers.get('Content-Type', '')
        file_extension = os.path.splitext(url)[1]

        mod_name = os.path.splitext(os.path.basename(url))[0]
        mod_extract_path = os.path.join(mod_dir, mod_name)

        # Save and extract the file based on type
        if 'application/zip' in content_type or file_extension == '.zip':
            extract_zip(response.content, mod_extract_path)
        else:
            print(f"Skipping {url} as it is not a supported archive file.")
            continue

        print(f"Downloaded and extracted {mod_name} successfully.")

    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")

print("Mods downloaded and extracted successfully.")