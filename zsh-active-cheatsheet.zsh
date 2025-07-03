#!/usr/bin/env zsh

# Interactive cheat sheet browser using FZF
# Binds to Ctrl+S for quick access to command cheats
# Features:
# - Browse and filter cheats with FZF
# - Execute commands directly or with placeholders for editing
# - Open source files in editor with Ctrl+E
# - Auto-prefix tmux commands
# - Smart cursor positioning for placeholder replacement

fzf_show_cheats() {

  # File paths and initialization
  local data_jsonl="$HOME/.cache/cheats-metadata.jsonl"
  local data_tsv=$(mktemp)
  local initial_query="$LBUFFER"

  # Clear current line after capturing search query
  LBUFFER=""
  RBUFFER=""

  # Prepare data for FZF display (TSV format with headers)
  {
    echo -e "ID\tType\tDomain\tTrigger\tShort"
    jq -r '[.ID, .Type, .Domain, .Trigger, .Short] | @tsv' "$data_jsonl"
  } | column -s $'\t' -t > "$data_tsv"

  # FZF selected row and ID
  local selected_row selected_id

  # FZF configuration and execution
  selected_row=$(fzf \
    --ansi --height=45% --reverse --info=inline \
    --prompt="Browse Cheats > " \
    --delimiter='\t' \
    --query="$initial_query" \
    --with-nth=1,2,3,4,5 --header-lines=1 \
    --preview-window=right:40%:wrap \
    --bind 'ctrl-e:execute-silent(
      id=$(echo {} | awk "{print \$1}")
      location=$(jq -r --arg id "$id" "select(.ID == \$id) | .Location // empty" '"$data_jsonl"')
      if [[ -n "$location" && -f "$location" ]]; then
        exec < /dev/tty
        exec > /dev/tty
        '"${EDITOR:-nano}"' "$location"
      fi
    )' \
    --header "Enter: Execute | Ctrl+E: Edit source file" \
    --preview "

      id=\$(echo {} | awk '{print \$1}')

      line=\$(grep -F -m1 \"\\\"ID\\\":\\\"\$id\\\"\" $data_jsonl)

      if [[ -n \$line ]]; then

        # Display metadata (excluding Function, Description, Example, Short)

        echo \"\$line\" | jq -r '

          to_entries
          | map(select(.key != \"Function\" and .key != \"Description\" and .key != \"Example\" and .key != \"Short\" and .key != \"Location\"))
          | (map(.key | length) | max) as \$w
          | .[]
          | \"\\u001b[1;34m\" + (.key + \":\") + \"\\u001b[0m\" + \"\\t\" + .value
        ' | column -s \$'\t' -t

        echo

        # Display Location if available

        location=\$(echo \"\$line\" | jq -r '.Location // empty')

        if [[ -n \$location ]]; then

          echo -e \"\\033[1;34mLocation:\\033[0m\"
          echo \"\$location\"
          echo

        fi


        # Display description if available

        desc=\$(echo \"\$line\" | jq -r '.Description // empty')

        if [[ -n \$desc ]]; then

          echo -e \"\\033[1;34mDescription:\\033[0m\"
          echo \"\$desc\"
          echo

        fi

        # Display example if available

        example=\$(echo \"\$line\" | jq -r '.Example // empty')

        if [[ -n \$example ]]; then

          echo -e \"\\033[1;34mExample:\\033[0m\"
          echo \"\$example\"
          echo

        fi

        # Display separator

        width=\$(printf '%s' \"\$FZF_PREVIEW_COLUMNS\" | grep -E '^[0-9]+$' || tput cols 2>/dev/null || stty size 2>/dev/null | cut -d' ' -f2 || echo 80)
        for ((i=0; i<width; i++)); do printf '─'; done

        echo
        echo

        # Display function with syntax highlighting

        echo \"\$line\" | jq -r '.Function' | batcat --language=sh --style=plain --color=always

      else

        echo 'No match'

      fi

    " \
    < "$data_tsv")

  # Cleanup and validation
  rm -f "$data_tsv"


  [[ -z "$selected_row" ]] && return 0 # Exit if no selection made

  # Extract selected command data
  selected_id=$(echo "$selected_row" | awk '{print $1}')
  local command domain executable
  command=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Function // empty' "$data_jsonl")
  domain=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Domain // empty' "$data_jsonl")
  executable=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Executable // "yes"' "$data_jsonl")

  # Validate command exists
  if [[ -z "$command" || "$command" == "null" ]]; then
    zle -M "No command found for '$selected_id'"
    return 1
  fi

  # Check if command is executable - silently return if not
  if [[ "$executable" != "yes" ]]; then
    return 0
  fi

  # Clean and prepare command
  command=$(clean_command "$command")
  command=$(add_domain_prefix "$command" "$domain")

  # Final validation
  if [[ -z "$command" ]]; then
    zle -M "Command is empty after processing"
    return 1
  fi

  # Execute or prepare command based on placeholder presence
  if command_has_placeholder "$command"; then
    setup_command_for_editing "$command"
  else
    execute_command_immediately "$command"
  fi
}

# Clean command string of unwanted whitespace and characters
clean_command() {
  local cmd="$1"
  printf '%s' "$cmd" | tr -d '\n\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Add domain-specific prefixes (e.g., tmux commands)
add_domain_prefix() {
  local cmd="$1"
  local domain="$2"

  if [[ "$domain" == "tmux" ]]; then
    echo "tmux $cmd"
  else
    echo "$cmd"
  fi
}

# Check if command contains placeholder patterns like <string>
command_has_placeholder() {
  local cmd="$1"
  [[ "$cmd" =~ '<[^>]+>' ]]
}

# Setup command for interactive editing (remove placeholder, position cursor)
setup_command_for_editing() {
  local cmd="$1"

  # Parse placeholder position
  local before_pattern="${cmd%%<*}"
  local after_pattern="${cmd#*>}"
  local cursor_pos=${#before_pattern}
  local cleaned_command="${before_pattern}${after_pattern}"

  # Set command line with cursor positioned at placeholder location
  LBUFFER="$cleaned_command"
  CURSOR=$cursor_pos
}

# Execute command immediately without user interaction
execute_command_immediately() {
  local cmd="$1"
  LBUFFER="$cmd"
  zle accept-line
}

# ZLE setup and key binding
stty -ixon                              # Disable Ctrl+S flow control
zle -N fzf_show_cheats                  # Register ZLE widget
bindkey '^S' fzf_show_cheats            # Bind to Ctrl+S
