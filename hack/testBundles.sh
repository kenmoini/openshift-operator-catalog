#!/bin/bash

# Fail on pull errors
set -e

# Check to see if yq is present
if ! command -v yq &> /dev/null; then
  echo "yq could not be found"
  exit 1
fi

# Get the script directory and go to the parent directory to be at the root of the project folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit

# Enable nullglob so that the pattern expands to nothing if no files are found
shopt -s nullglob

# Loop through each YML/YAML file in the bundles directory
for file in bundles/*.{yml,yaml}; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Process the YAML file
    bundleName=$(yq -r '.name' "$file")
    echo "Processing $file - $bundleName"
    while IFS=$'\t' read -r img _; do
      echo "- Bundle Image:  $img"
      podman pull "$img"
    done < <(yq -r '.bundles[] | .image' "$file")
  fi
done


echo "All bundle images have been tested."
