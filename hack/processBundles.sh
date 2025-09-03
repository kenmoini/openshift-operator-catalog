#!/bin/bash

# Check if the first arg is -q for quiet mode
QUIET_MODE=false
if [[ "$1" == "-q" ]]; then
  QUIET_MODE=true
fi

# Check to see if yq is present
if ! command -v yq &> /dev/null; then
  if [ "$QUIET_MODE" =  false ]; then
    echo "yq could not be found"
  fi
  exit
fi

# Get the script directory and go to the parent directory to be at the root of the project folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit

# Enable nullglob so that the pattern expands to nothing if no files are found
shopt -s nullglob

BUNDLE_IMAGES=""

# Loop through each YML/YAML file in the bundles directory
for file in bundles/*.{yml,yaml}; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Process the YAML file
    bundleName=$(yq -r '.name' "$file")
    if [ "$QUIET_MODE" =  false ]; then
      echo "Processing $file - $bundleName"
    fi
    while IFS=$'\t' read -r img _; do
      if [ "$QUIET_MODE" =  false ]; then
        echo "Bundle Image:  $img"
      fi
      BUNDLE_IMAGES+=",$img"
    done < <(yq -r '.bundles[] | .image' "$file")
    #
  fi
done

# Remove leading comma
BUNDLE_IMAGES=${BUNDLE_IMAGES:1}

echo "$BUNDLE_IMAGES"
