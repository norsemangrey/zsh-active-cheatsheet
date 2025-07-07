#!/usr/bin/env bash

# Enable strict error handling
set -euo pipefail

# Debug configuration - controlled by --debug flag
DEBUG=0

# Check if running from plugin context (suppress some output)
PLUGIN_MODE=0
if [[ "${1:-}" == "--plugin-mode" ]]; then
  PLUGIN_MODE=1
  shift
fi

# Debug function - only works outside plugin mode
debug() {
  if [[ $DEBUG -eq 1 && $PLUGIN_MODE -eq 0 ]]; then
    echo "[DEBUG] $*" >&2
  fi
}

# Function to display usage information
usage() {
  echo "Usage: $0 [OPTIONS] [directory1] [directory2] ..."
  echo ""
  echo "Scan directories for cheat files and generate metadata."
  echo ""
  echo "Options:"
  echo "  -i, --ignore STRING    Add string to ignore list (can be used multiple times)"
  echo "  -d, --debug            Enable debug output"
  echo "  -h, --help             Show this help message"
  echo "  --plugin-mode          Run in plugin mode (suppress non-error output)"
  echo ""
  echo "Arguments:"
  echo "  directory              Directory to scan for cheat files (can specify multiple)"
  echo ""
  echo "Default ignore patterns:"
  echo "  .git, .svn, node_modules, cache, plugins, .cache, backup, backups,"
  echo "  tmp, temp, .tmp, logs, log, .DS_Store, Thumbs.db, vendor, build,"
  echo "  dist, target, .vscode, .idea"
  echo ""
  echo "If no directories are provided, defaults to:"
  echo "  \$HOME/.config/aliases"
  echo "  \$HOME/.config/cheats"
  echo ""
  echo "Examples:"
  echo "  $0                                    # Use defaults"
  echo "  $0 /path/to/cheats                   # Scan single directory"
  echo "  $0 -i custom_ignore                  # Add custom ignore pattern"
  echo "  $0 --debug --ignore test /path1      # Debug mode with additional ignore"
}

# Initialize arrays with default ignore strings
declare -a ignore_strings=(
  "git"
  "cache"
  "plugins"
  "backup"
  "log"
)

# Declare directories array
declare -a directories_to_scan=()

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -d|--debug)
      DEBUG=1
      shift
      ;;
    -i|--ignore)
      if [[ -n "${2:-}" ]]; then
        ignore_strings+=("$2")
        shift 2
      else
        echo "Error: --ignore requires a string argument" >&2
        exit 1
      fi
      ;;
    --plugin-mode)
      # Already handled at the top, just consume the argument
      shift
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      # This is a directory argument
      directories_to_scan+=("$1")
      shift
      ;;
  esac
done

# Set default directories if none provided
if [[ ${#directories_to_scan[@]} -eq 0 ]]; then
  # Default directories to scan
  directories_to_scan=(
    "$HOME/.config/aliases"
    "$HOME/.config/cheats"
  )
  debug "Using default directories: ${directories_to_scan[*]}"
else
  debug "Using provided directories: ${directories_to_scan[*]}"
fi

# Display ignore strings if any (including defaults)
if [[ ${#ignore_strings[@]} -gt 0 ]]; then
  debug "Will skip paths containing: ${ignore_strings[*]}"
fi

# Simple function to check if a path should be ignored
should_ignore_path() {
  local path="$1"

  # Check each ignore string
  for ignore_string in "${ignore_strings[@]}"; do
    # Check if the path contains the ignore string
    if [[ "$path" == *"$ignore_string"* ]]; then
      debug "Skipping path containing '$ignore_string': $path"
      return 0
    fi
  done

  return 1
}

# Enhanced validate_directories function
validate_directories() {
  local valid_directories=()

  # Iterate over each directory to validate
  for directory in "${directories_to_scan[@]}"; do
    # Check if the directory exists
    if [[ -d "$directory" ]]; then
      # Check if the directory is not ignored
      if should_ignore_path "$directory"; then
        debug "Ignoring directory: $directory"
        continue
      fi

      # Add to valid directories
      valid_directories+=("$directory")
      debug "Valid directory found: $directory"
    else
      debug "Warning: Skipping non-existent directory: $directory"
    fi
  done

  if [[ ${#valid_directories[@]} -eq 0 ]]; then
    echo "Error: No valid directories found to scan" >&2
    exit 1
  fi

  # Update the global directories to scan with valid directories
  directories_to_scan=("${valid_directories[@]}")
  debug "Total valid directories: ${#directories_to_scan[@]}"
}

# Output file for metadata
output_file="$HOME/.cache/cheats-metadata.jsonl"
> "$output_file"

debug "Output file: $output_file"
debug "Directories to scan: ${directories_to_scan[*]}"

# Initialize counter for generating unique IDs
counter=1

# Validate directories upfront
validate_directories

# Metadata fields (ID and Location are automatically generated)
readonly fields=(
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
readonly field_pattern=$(IFS='|'; echo "${fields[*]:2}")

debug "Field pattern: $field_pattern"

# Initialize associative array to hold cheat fields
declare -A cheat_fields

# Initialize all fields except ID and Location
initialize_fields() {

  debug "Initializing field map"

  # Iterate over all fields
  for field in "${fields[@]}"; do

    # Initialize each field to an empty string
    cheat_fields["$field"]=""

  done

}

# Global variable to track number of splits needed
declare -g split_count=1

# Function to count pipe-separated alternatives in a trigger
count_trigger_splits() {

  # Get the trigger string
  local trigger="$1"

  debug "Analyzing trigger for splits: '$trigger'"

  # Check if trigger contains the pattern (content | content | ...)
  if [[ $trigger =~ \([^\)]*\|[^\)]*\) ]]; then

    # Extract content within parentheses
    local paren_content="${trigger#*(}"
    paren_content="${paren_content%)*}"

    # Count the number of alternatives (count of | + 1)
    local count=$(echo "$paren_content" | tr -cd '|' | wc -c)
    count=$((count + 1))

    debug "Found $count alternatives in trigger"

    # Output the count
    echo "$count"

  else

    debug "No pipe pattern found in trigger"

    # Default to 1 if no pipe pattern is found
    echo "1"

  fi

}

# Function to extract a specific alternative from multiple pipe-separated patterns
extract_alternative() {

  # Get the value and index from arguments
  local value="$1"
  local index="$2"

  debug "Extracting alternative $index from: '$value'"

  # Start with the original value
  local result="$value"

  # Process all pipe patterns in the value using a while loop
  while [[ $result =~ \(([^\)]*\|[^\)]*)\) ]]; do

    # Get the full match and content inside parentheses
    local full_pattern="${BASH_REMATCH[0]}"  # Full match including parentheses
    local paren_content="${BASH_REMATCH[1]}" # Content inside parentheses

    debug "  Found pattern: '$full_pattern' with content: '$paren_content'"

    # Declare an array to hold alternatives
    local -a alternatives

    # Use IFS to split the alternatives by pipe
    IFS='|' read -ra alternatives <<< "$paren_content"

    # Check if index is valid
    if [[ $index -le ${#alternatives[@]} ]]; then

      # Get the specific alternative (arrays are 0-indexed, so subtract 1)
      local alternative="${alternatives[$((index-1))]}"

      # Trim whitespace
      alternative="${alternative#"${alternative%%[![:space:]]*}"}"
      alternative="${alternative%"${alternative##*[![:space:]]}"}"

      # Replace the first occurrence of the pattern
      result="${result/$full_pattern/$alternative}"

      debug "  Replaced '$full_pattern' with '$alternative'"

    else

      # If index is out of range, use the first alternative
      local alternative="${alternatives[0]}"

      # Trim whitespace from the alternative
      alternative="${alternative#"${alternative%%[![:space:]]*}"}"
      alternative="${alternative%"${alternative##*[![:space:]]}"}"

      # Replace the first occurrence of the pattern with the first alternative
      result="${result/$full_pattern/$alternative}"

      debug "  Index $index out of range, used first alternative: '$alternative'"

    fi
  done

  debug "Final extracted result: '$result'"

  # Return the final result
  echo "$result"

}

# Process current line in the file
process_line() {

  # Read the line passed as argument
  local line="$1"

  # Determine start of a cheat block ("# Cheat")
  if [[ $line =~ ^#[[:space:]]*Cheat$ ]]; then

    debug "Found cheat block start"

    # Set the cheat block flag
    inside_block=1

    # Initialize fields for each cheat block
    initialize_fields

    # Reset split count for new cheat block
    split_count=1

    return

  fi

  # Check if we are inside a cheat block
  if [[ $inside_block -eq 1 ]]; then

    debug "Inside cheat block, processing line"

    # Remove any leading comment marker
    clean_line="${line#\# }"

    debug "Cleaned line: '$clean_line'"

    # Check if the line matches a field pattern
    if [[ $clean_line =~ ^(${field_pattern})[[:space:]]+(.+)$ ]]; then

      debug "Line matches field pattern"

      # Extract key and value using regex capture groups
      local key="${BASH_REMATCH[1]}"    # First group: field name
      local value="${BASH_REMATCH[2]}"  # Second group: field value

      debug "Extracted key: '$key', value: '$value'"

      # Store key-value pair in associative array
      cheat_fields["$key"]="$value"

      # If this is the Trigger field, check for pipe patterns
      if [[ "$key" == "Trigger" ]]; then

        # Count the number of splits needed
        split_count=$(count_trigger_splits "$value")

        debug "Split count set to: $split_count"

      fi

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

  # Set the Location field to the current file being processed
  cheat_fields["Location"]="$current_file"

  # Emit the JSON object for the current cheat (this will handle ID assignment)
  emit_json

  # Reset the cheat block flag
  inside_block=0

  debug "Cheat finalized, inside_block reset to 0"

}

# Emit JSON object to output file
emit_json() {

  debug "Emitting JSON for cheat with $split_count splits"

  # Create the specified number of JSON entries
  for ((i=1; i<=split_count; i++)); do

    debug "Creating JSON entry $i of $split_count"

    # Generate unique ID for this entry
    local current_id=$(printf "%03d" "$counter")

    debug "Assigning ID: $current_id"

    # Start JSON object
    local json="{"

    # Iterate over all fields
    for field in "${fields[@]}"; do

      # Initialize value
      local value=""

      # Handle ID field specially
      if [[ "$field" == "ID" ]]; then

        # Assign the current ID
        value="$current_id"

      else

        # For other fields, get the value from the associative array
        value="${cheat_fields[$field]:-""}"

        # For fields that might contain pipe patterns, extract the appropriate alternative
        if [[ $split_count -gt 1 && $value =~ \([^\)]*\|[^\)]*\) ]]; then

          # Extract the i-th alternative from the value
          value=$(extract_alternative "$value" "$i")

          debug "  Split $field ($i): '$value'"

        else

          debug "  $field: '$value'"

        fi

      fi

      # Escape double quotes for JSON
      value=${value//\"/\\\"}

      # Add field to JSON object
      json+="\"$field\":\"$value\","

    done

    # Remove trailing comma and close JSON object
    json="${json%,}}"

    # Write JSON object to output file
    echo "$json" >> "$output_file"

    debug "JSON entry $i written to output file with ID: $current_id"

    # Increment counter for next entry
    ((counter++))

  done

  debug "All JSON entries written to output file"

}

# Iterate over each directory to scan
for directory in "${directories_to_scan[@]}"; do

  debug "Scanning directory: $directory"

  # Build find command with ignore patterns using -prune for better performance
  find_command="find -L \"$directory\""

  # Add prune conditions for ignore patterns if any exist
  if [[ ${#ignore_strings[@]} -gt 0 ]]; then

    # Start a new condition group
    find_command+=" \\("

    # Add each ignore pattern as a -path condition
    for i in "${!ignore_strings[@]}"; do

      # Check if this is the first ignore string
      if [[ $i -gt 0 ]]; then

        # Add -o (OR) operator for subsequent ignore patterns
        find_command+=" -o"

      fi

      # Add the -path condition for the current ignore string
      find_command+=" -path \"*${ignore_strings[i]}*\""

    done

    # Close the ignore condition group
    find_command+=" \\) -prune -o"

  fi

  # Add the final condition to find regular files
  find_command+=" -type f -print"

  #debug "Find command: $find_command"

  # Execute the find command and iterate over each file
  while read -r current_file; do

    # Skip empty lines
    [[ -z "$current_file" ]] && continue

    # Check if file is readable
    if [[ ! -r "$current_file" ]]; then

      #debug "Skipping unreadable file: $current_file"

      continue

    fi

    #debug "Processing file: $current_file"

    # Initialize the cheat block flag
    inside_block=0

    #debug "Reset inside_block to 0 for new file"

    # Read the file line by line (use -r to handle backslashes correctly)
    while IFS= read -r line || [[ -n $line ]]; do

      #debug "Reading line: '$line'"

      # Process the current line
      process_line "$line"

    done < "$current_file" # Read the current file

    # Check if we reach the end of the file while inside a cheat block
    if [[ $inside_block -eq 1 ]]; then

      #debug "End of file reached while inside cheat block, finalizing"

      # Finalize the current cheat block
      finalize_fields

    fi

    #debug "Finished processing file: $current_file"

  done < <(eval "$find_command")

  debug "Finished scanning directory: $directory"

done

debug "Processing complete. Total cheats processed: $((counter - 1))"
