#!/usr/bin/env zsh

# ZSH Active Cheatsheet Plugin
# Provides interactive cheat sheet browser with Ctrl+S keybinding
# Auto-compiles cheat metadata on ZSH startup

# Get plugin directory and make it global for functions to use
typeset -g ZSH_ACTIVE_CHEATSHEET_PLUGIN_DIR="${0:A:h}"

# Ensure cache directory exists
mkdir -p "$HOME/.cache"

# Configuration variables (can be set by user in .zshrc)
# Default directories to scan for cheat files
typeset -ga ZSH_ACTIVE_CHEATSHEET_DIRS
: ${ZSH_ACTIVE_CHEATSHEET_DIRS:=("$HOME/.config/aliases" "$HOME/.config/cheats")}

# Additional ignore patterns (added to defaults)
typeset -ga ZSH_ACTIVE_CHEATSHEET_IGNORE
: ${ZSH_ACTIVE_CHEATSHEET_IGNORE:=()}

# Enable/disable auto-compilation on startup
: ${ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE:=true}

# Debug mode
: ${ZSH_ACTIVE_CHEATSHEET_DEBUG:=false}

# Syntax highlighter for function preview (default: cat)
: ${ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER:=cat}

# Auto-compile cheats metadata on plugin load (if enabled)
if [[ "$ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE" == "true" ]]; then
    () {
        local compiler="$ZSH_ACTIVE_CHEATSHEET_PLUGIN_DIR/cheats-compiler.sh"

        if [[ -x "$compiler" ]]; then
            # Build compiler arguments
            local compiler_args=("--plugin-mode")

            # Add debug flag if enabled
            if [[ "$ZSH_ACTIVE_CHEATSHEET_DEBUG" == "true" ]]; then
                compiler_args+=("--debug")
            fi

            # Add custom ignore patterns
            for ignore_pattern in "${ZSH_ACTIVE_CHEATSHEET_IGNORE[@]}"; do
                compiler_args+=("--ignore" "$ignore_pattern")
            done

            # Add directories to scan
            compiler_args+=("${ZSH_ACTIVE_CHEATSHEET_DIRS[@]}")

            # Run compiler in background with proper job control
            if [[ "$ZSH_ACTIVE_CHEATSHEET_DEBUG" == "true" ]]; then
                # In debug mode, show output but run in background
                "$compiler" "${compiler_args[@]}" &
                # Only disown if there's actually a job to disown
                if (( $? == 0 )); then
                    disown 2>/dev/null || true
                fi
            else
                # In normal mode, suppress ALL output (stdout and stderr)
                "$compiler" "${compiler_args[@]}" >/dev/null 2>&1 &
                # Only disown if there's actually a job to disown
                if (( $? == 0 )); then
                    disown 2>/dev/null || true
                fi
            fi
        else
            # Only show warning if debug is enabled
            if [[ "$ZSH_ACTIVE_CHEATSHEET_DEBUG" == "true" ]]; then
                print "Warning: zsh-active-cheatsheet compiler not found or not executable at $compiler" >&2
            fi
        fi
    } &!  # Run in background subshell
fi

# Source the main functionality
source "$ZSH_ACTIVE_CHEATSHEET_PLUGIN_DIR/zsh-active-cheatsheet.zsh"

# Utility function for manual compilation
zsh-active-cheatsheet-compile() {

    local compiler="$ZSH_ACTIVE_CHEATSHEET_PLUGIN_DIR/cheats-compiler.sh"

    if [[ -x "$compiler" ]]; then
        local compiler_args=()

        # Add debug flag if enabled
        if [[ "$ZSH_ACTIVE_CHEATSHEET_DEBUG" == "true" ]]; then
            compiler_args+=("--debug")
        fi

        # Add custom ignore patterns
        for ignore_pattern in "${ZSH_ACTIVE_CHEATSHEET_IGNORE[@]}"; do
            compiler_args+=("--ignore" "$ignore_pattern")
        done

        # Add directories to scan
        compiler_args+=("${ZSH_ACTIVE_CHEATSHEET_DIRS[@]}")

        # Run compiler with current configuration (show output for manual runs)
        "$compiler" "${compiler_args[@]}"
    else
        print "Error: Compiler not found at $compiler" >&2
        return 1
    fi
}

# Optional: Add plugin unload function
zsh-active-cheatsheet-unload() {

    # Remove keybinding
    bindkey -r '^S'

    # Remove widget
    zle -D fzf_show_cheats 2>/dev/null || true

    # Remove utility function
    unfunction zsh-active-cheatsheet-compile 2>/dev/null || true
}
