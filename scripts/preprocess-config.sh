#!/bin/bash

# Usage: preprocess-config.sh <template_file> <output_file>
TEMPLATE_FILE=$1
OUTPUT_FILE=$2

if [[ -z "$TEMPLATE_FILE" || -z "$OUTPUT_FILE" ]]; then
  echo "Usage: preprocess-config.sh <template_file> <output_file>"
  exit 1
fi

# Check if the template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file $TEMPLATE_FILE does not exist."
  exit 1
fi

# Perform variable substitution and create the output file
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
echo "Created $OUTPUT_FILE"