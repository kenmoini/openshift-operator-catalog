#!/bin/bash

# Fail on pull errors
set -e

COMBINED_OLM_TEMPLATE="combined-olm-template.yaml"

# Pull in env var or set default
export CONTAINER_TOOL=${CONTAINER_TOOL:-podman}

mkdir -p fbc

# Check to see if CONTAINER_TOOL is present
if ! command -v ${CONTAINER_TOOL} &> /dev/null; then
  echo "${CONTAINER_TOOL} could not be found"
  exit 1
fi

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

echo "===== Combining OLM templates into $COMBINED_OLM_TEMPLATE"
echo "schema: olm.template.basic" > "$COMBINED_OLM_TEMPLATE"
echo "entries: []" >> "$COMBINED_OLM_TEMPLATE"

# Loop through each YML/YAML file in the bundles directory
for file in olm-templates/*.{yml,yaml}; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Process the YAML file
    echo "===== Processing $file"
    # Combine the entries into a single OLM template
    yq -i '.entries += load("'"$file"'").entries' "$COMBINED_OLM_TEMPLATE"
  fi
done

# Generate the FBC
echo "===== Generating FBC from $COMBINED_OLM_TEMPLATE"
./bin/opm alpha render-template basic "$COMBINED_OLM_TEMPLATE" -o yaml > fbc/index.yaml

# Generate the dockerfile
echo "===== Generating Dockerfile for FBC"
rm -f fbc.Dockerfile
./bin/opm generate dockerfile fbc