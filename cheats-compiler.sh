#!/usr/bin/env bash

# Enable strict error handling
set -euo pipefail

# Debug configuration - set to 1 to enable debugging
DEBUG=${DEBUG:-0}

# Debug output function
debug() {
  [[ $DEBUG -eq 1 ]] && echo "[DEBUG] $*" >&2
}

# Directories to scan — customize as needed
directories_to_scan=(
  "$HOME/.config/aliases"
  "$HOME/.config/cheats"
)

# Output file for metadata
output_file="$HOME/.cache/cheats-metadata.jsonl"
> "$output_file"

debug "Output file: $output_file"
debug "Directories to scan: ${directories_to_scan[*]}"

# Validate directories upfront
validate_directories() {

  # Array to hold valid directories
  local valid_directories=()

  # Iterate over each directory to check if it exists
  for directory in "${directories_to_scan[@]}"; do

    # Check if the directory exists
    if [[ -d "$directory" ]]; then

      # Add directory to valid directories
      valid_directories+=("$directory")

    else

      debug "Skipping non-existent directory: $directory"

    fi

  done

    # Update the global variable
    directories_to_scan=("${valid_directories[@]}")

}

# Initialize all fields except ID and Location
initialize_field_map() {

  debug "Initializing field map"

  # Iterate over all fields
  for field in "${fields[@]}"; do

    # Initialize field to empty string
    [[ "$field" != "ID" && "$field" != "Location" ]] && eval "$field=\"\""

  done

}

# Process each line of the file
process_line() {

  local line="$1"

  # Determine start of a cheat block ("# Cheat")
  if [[ $line =~ ^#[[:space:]]*Cheat$ ]]; then

    debug "Found cheat block start"

    # Set the cheat block flag
    inside_block=1

    # Initialize fields for each cheat block
    initialize_field_map

    return

  fi

  # Check if we are inside a cheat block
  if [[ $inside_block -eq 1 ]]; then

    debug "Inside cheat block, processing line"

    # Remove any leading comment marker
    clean_line="${line#\# }"

    debug "Cleaned line: '$clean_line'"

    # Check if the line matches a field pattern
    if [[ $clean_line =~ ^(${field_pattern})[[:space:]]+ ]]; then

      debug "Line matches field pattern"

      # Extract key by 'removing match from end' (first space)
      local key="${clean_line%% *}"

      # Extract value by 'removing match from start' (first space)
      local value="${clean_line#* }"

      debug "Extracted key: '$key', value: '$value'"

      # Create a variable with the key name and assign the value
      eval "$key=\"\$value\""

      debug "Set variable $key to '$value'"

    else

      debug "Line does not match field pattern, finalizing cheat"

      # Finalize the current cheat block
      finalize_fields

    fi

  else

    debug "Outside cheat block, skipping line"

  fi

}

# Finalize the current cheat block
finalize_fields() {

  debug "Finalizing cheat (counter: $counter)"

  # Generate ID based on the current counter
  ID=$(printf "%03d" "$counter")

  # Set the Location field to the current file being processed
  Location="$current_file"

  # Increment the counter
  ((counter++))

  # Emit the JSON object for the current cheat
  emit_json

  # Reset the cheat block flag
  inside_block=0

  debug "Cheat finalized, inside_block reset to 0"

}

# Emit JSON object to output file
emit_json() {

  debug "Emitting JSON for cheat ID: $ID"

  # Start JSON object
  local json="{"

  # Iterate over all fields
  for field in "${fields[@]}"; do

    # Get the value of the field, default to empty string if not set
    value=${!field:-""}

    # Escape double quotes for JSON
    value=${value//\"/\\\"}

    # Add field to JSON object
    json+="\"$field\":\"$value\","

    debug "  $field: '$value'"

  done

  # Remove trailing comma and close JSON object
  json="${json%,}}"

  # Write JSON object to output file
  echo "$json" >> "$output_file"

  debug "JSON written to output file"

}

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
  "Executable"
  "Description"
  "Short"
  "Example"
)

# Only match user-defined fields (exclude ID, Location)
field_pattern=$(IFS='|'; echo "${fields[*]:2}")

debug "Field pattern: $field_pattern"

# Validate directories before processing
validate_directories

# Initialize the cheat counter
counter=1

debug "Starting processing with counter: $counter"

# Iterate over each directory to scan
for directory in "${directories_to_scan[@]}"; do

  debug "Scanning directory: $directory"

  # Check if the directory exists
  if [[ ! -d "$directory" ]]; then

    debug "Directory does not exist: $directory"

    continue

  fi

  # Iterate over each file in the directory
  while read -r current_file; do

    debug "Processing file: $current_file"

    # Initialize the cheat block flag
    inside_block=0

    debug "Reset inside_block to 0 for new file"

    # Read the file line by line (use -r to handle backslashes correctly)
    while IFS= read -r line || [[ -n $line ]]; do

      debug "Reading line: '$line'"

      # Process the current line
      process_line "$line"

    done < "$current_file" # Read the current file

    # Check if we reach the end of the file while inside a cheat block
    if [[ $inside_block -eq 1 ]]; then

      debug "End of file reached while inside cheat block, finalizing"

      # Finalize the current cheat block
      finalize_fields

    fi

    debug "Finished processing file: $current_file"

  done < <(find -L "$directory" -type f) # Find all files in the directory

  debug "Finished scanning directory: $directory"

done

debug "Processing complete. Total cheats processed: $((counter - 1))"
