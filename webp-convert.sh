#!/bin/bash

# Ask for quality values interactively
read -p "Enter JPEG quality (0-100, default 85): " jpeg_quality
jpeg_quality=${jpeg_quality:-85}

read -p "Enter PNG quality (0-100, default 95): " png_quality
png_quality=${png_quality:-95}

read -p "Enter alpha quality (0-100, default 95): " alpha_quality
alpha_quality=${alpha_quality:-95}

# Directory argument
directory=$1

# Check if directory is provided
if [ -z "$directory" ]; then
  echo "Directory is required."
  exit 1
fi

# Remove all files that are not PNG
find "$directory" -type f ! -iname "*.png" -exec rm -v {} +

# converting JPEG images
find "$directory" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) \
-exec bash -c '
jpeg_quality=$jpeg_quality
webp_path=$(sed "s/\.[^.]*$/.webp/" <<< "$0");
jpg_path=$(sed "s/\.[^.]*$/-min.jpg/" <<< "$0");
if [ ! -f "$webp_path" ]; then 
  echo "$webp_path image ok";
  cwebp -quiet -q '"$jpeg_quality"' "$0" -o "$webp_path";
  convert "$0" -quality '"$jpeg_quality"' "$jpg_path";
fi;' {} \;

# converting PNG images
find "$directory" -type f -iname "*.png" \
-exec bash -c '
png_quality=$png_quality
alpha_quality=$alpha_quality
webp_path=$(sed "s/\.[^.]*$/.webp/" <<< "$0");
jpg_path=$(sed "s/\.[^.]*$/.jpg/" <<< "$0");
if [ ! -f "$webp_path" ]; then 
  echo "$webp_path image ok";
  cwebp -quiet -alpha_q '"$alpha_quality"' -q '"$png_quality"' "$0" -o "$webp_path";
  convert "$0" -quality '"$png_quality"' "$jpg_path";
fi;' {} \;
