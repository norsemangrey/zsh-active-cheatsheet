fzf_show_cheats() {

  local data_jsonl="$HOME/.cache/cheats-metadata.jsonl"
  local data_tsv
  data_tsv=$(mktemp)
  local initial_query="$LBUFFER"

  {
    echo -e "ID\tType\tDomain\tTrigger\tShort"
    jq -r '[.ID, .Type, .Domain, .Trigger, .Short] | @tsv' "$data_jsonl"
  } | column -s $'\t' -t > "$data_tsv"

  local selected_row selected_id
  selected_row=$(fzf --ansi --height=45% --reverse --info=inline \
      --prompt="Browse Cheats > " \
      --delimiter='\t' \
      --query="$initial_query" \
      --with-nth=1,2,3,4,5 --header-lines=1 --preview-window=right:40%:wrap \
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
        echo \"\$line\" | jq -r '
          to_entries
          | map(select(.key != \"Function\" and .key != \"Description\" and .key != \"Example\" and .key != \"Short\"))
          | (map(.key | length) | max) as \$w
          | .[]
          | \"\\u001b[1;34m\" + (.key + \":\") + \"\\u001b[0m\" + \"\\t\" + .value
        ' | column -s \$'\t' -t
          echo
          desc=\$(echo \"\$line\" | jq -r '.Description // empty')
          if [[ -n \$desc ]]; then
            echo -e \"\\033[1;34mDescription:\\033[0m\"
            echo \"\$desc\"
            echo
          fi

          example=\$(echo \"\$line\" | jq -r '.Example // empty')
          if [[ -n \$example ]]; then
            echo -e \"\\033[1;34mExample:\\033[0m\"
            echo \"\$example\"
            echo
          fi

          width=\$(printf '%s' \"\$FZF_PREVIEW_COLUMNS\" | grep -E '^[0-9]+$' || tput cols 2>/dev/null || stty size 2>/dev/null | cut -d' ' -f2 || echo 80)
          for ((i=0; i<width; i++)); do printf '─'; done
          echo

          echo
          echo \"\$line\" | jq -r '.Function' | batcat --language=sh --style=plain --color=always
        else
          echo 'No match'
        fi
      " < "$data_tsv")

  # Clean up temporary files
  rm -f "$data_tsv"
  [[ -z "$selected_row" ]] && return 0

  # Extract just the trigger from the selected row
  selected_id=$(echo "$selected_row" | awk '{print $1}')

  # Extract the Command field from matching JSON
  local command domain
  command=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Function // empty' "$data_jsonl")
  domain=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Domain // empty' "$data_jsonl")

  # Check if command is valid before processing
  if [[ -z "$command" || "$command" == "null" ]]; then
    zle -M "No command found for '$selected_id'"
    return 1
  fi

  # Clean the command string - remove any newlines or extra whitespace
  command=$(printf '%s' "$command" | tr -d '\n\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Prefix with tmux if Domain is tmux
  if [[ "$domain" == "tmux" ]]; then
    command="tmux $command"
  fi

  # Validate command is not empty after cleaning
  if [[ -z "$command" ]]; then
    zle -M "Command is empty after processing"
    return 1
  fi

  # Check if command contains <string> pattern
  if [[ "$command" =~ '<[^>]+>' ]]; then
    # Command has placeholder - set up for editing

    # Find the first < character
    local before_pattern="${command%%<*}"

    # Find everything after the first >
    local after_pattern="${command#*>}"

    # Calculate cursor position
    local cursor_pos=${#before_pattern}

    # Combine before and after
    local cleaned_command="${before_pattern}${after_pattern}"

    # Set the command line
    LBUFFER="$cleaned_command"
    CURSOR=$cursor_pos

  else
    # No placeholder - execute immediately
    LBUFFER="$command"
    zle accept-line
  fi
}

stty -ixon
zle -N fzf_show_cheats
bindkey '^S' fzf_show_cheats
