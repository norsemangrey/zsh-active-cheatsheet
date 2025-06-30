#!/usr/bin/env bash

set -euo pipefail

# Directories to scan — customize as needed
dirs_to_scan=(
  "$HOME/.config/aliases"
  "$HOME/.config/cheats"
)

output_file="$HOME/.cache/cheats-metadata.jsonl"
> "$output_file"

# Metadata fields (ID and Location are automatically generated)
fields=(
  "ID"
  "Location"
  "Type"
  "Trigger"
  "Domain"
  "Conditional"
  "Alternative"
  "Function"
  "Description"
  "Example"
  "Short"
)

# Only match user-defined fields (exclude ID, Location)
field_pattern=$(IFS='|'; echo "${fields[*]:2}")

# Initialize all fields except ID and Location
init_field_map() {
  for field in "${fields[@]}"; do
    [[ "$field" != "ID" && "$field" != "Location" ]] && eval "$field=\"\""
  done
}

emit_json() {
  local json="{"
  for field in "${fields[@]}"; do
    value=${!field:-""}
    value=${value//\"/\\\"}
    json+="\"$field\":\"$value\","
  done
  json="${json%,}}"
  echo "$json" >> "$output_file"
}

counter=1

for dir in "${dirs_to_scan[@]}"; do
  while read -r current_file; do
    inside_block=0
    init_field_map

    while IFS= read -r line || [[ -n $line ]]; do
      if [[ $line =~ ^#[[:space:]]*Cheat$ ]]; then
        inside_block=1
        init_field_map
        continue
      fi

      if [[ $inside_block -eq 1 ]]; then
        clean_line="${line#\# }"

        if [[ $clean_line =~ ^(${field_pattern})[[:space:]]+ ]]; then
          key=$(cut -d' ' -f1 <<< "$clean_line")
          value=$(sed -E "s/^${key}[[:space:]]+//" <<< "$clean_line")
          eval "$key=\"\$value\""
        else
          ID=$(printf "%03d" "$counter")
          Location="$current_file"
          ((counter++))
          emit_json
          inside_block=0
        fi
      fi
    done < "$current_file"

    if [[ $inside_block -eq 1 ]]; then
      ID=$(printf "%03d" "$counter")
      Location="$current_file"
      ((counter++))
      emit_json
    fi
  done < <(find -L "$dir" -type f)
done
