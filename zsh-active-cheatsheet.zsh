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
      --with-nth=1,2,3,4,5 --header-lines=1 --preview-window=right:40%:wrap --preview "
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

  #rm -f "$data_tsv"
  [[ -z "$selected_row" ]] && return 0

  # Extract just the trigger from the selected row
  selected_id=$(echo "$selected_row" | awk '{print $1}')

  # Extract the Command field from matching JSON
  local command domain
  command=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Function // empty' "$data_jsonl")
  domain=$(jq -r --arg id "$selected_id" 'select(.ID == $id) | .Domain // empty' "$data_jsonl")

  # Prefix with tmux if Domain is tmux
  if [[ "$domain" == "tmux" ]]; then
    command="tmux $command"
  fi

  if [[ -n "$command" ]]; then
    LBUFFER="$command"

    # Accept the line to execute the command
    zle accept-line

  else
    zle -M "No command found for '$selected_id'"
  fi
}

stty -ixon
zle -N fzf_show_cheats
bindkey '^S' fzf_show_cheats
