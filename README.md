# zsh-active-cheatsheet

Interactive cheat sheet browser for zsh using FZF. Press `Ctrl+S` to browse and execute commands from your personal cheat collection.

## Installation

### Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/norsemangrey/zsh-active-cheatsheet.git ~/.config/zsh/plugins/zsh-active-cheatsheet

# 2. Configure (optional)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# 3. Source the PLUGIN file (not the core file)
source ~/.config/zsh/plugins/zsh-active-cheatsheet/zsh-active-cheatsheet.plugin.zsh
```

### Using Oh My Zsh

```bash
# 1. Clone to custom plugins
git clone https://github.com/norsemangrey/zsh-active-cheatsheet.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-active-cheatsheet

# 2. Configure in ~/.zshrc (before plugins line)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# 3. Add to plugins
plugins=(... zsh-active-cheatsheet)
```

### Using Zinit

```bash
# Configure before loading (optional)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats" "$HOME/.config/aliases")

zinit load "norsemangrey/zsh-active-cheatsheet"
```

## Configuration

### Environment Variables

Configure the plugin by setting these variables in your `.zshrc` **before** loading the plugin:

#### `ZSH_ACTIVE_CHEATSHEET_DIRS`
**Default**: `("$HOME/.config/aliases" "$HOME/.config/cheats")`

Directories to scan for cheat files:
```bash
# Single directory
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# Multiple directories
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/cheats"
    "$HOME/work/docs"
    "$HOME/.local/share/cheats"
)

# Include defaults + custom
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/.config/aliases"    # default
    "$HOME/.config/cheats"     # default
    "$HOME/my-custom-cheats"   # custom
)
```

#### `ZSH_ACTIVE_CHEATSHEET_IGNORE`
**Default**: `()`

Additional patterns to ignore (beyond built-in defaults):
```bash
# Ignore sensitive files
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("secret" "private" ".env")

# Ignore specific directories
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("old" "archive" "deprecated")
```

#### `ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE`
**Default**: `true`

Enable/disable automatic compilation on zsh startup:
```bash
# Disable auto-compilation (compile manually)
export ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE=false
```

#### `ZSH_ACTIVE_CHEATSHEET_DEBUG`
**Default**: `false`

Enable debug output during compilation:
```bash
# Enable debug mode
export ZSH_ACTIVE_CHEATSHEET_DEBUG=true
```

#### `ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER`
**Default**: `cat`

Syntax highlighter for function preview in FZF:
```bash
# Use bat/batcat for syntax highlighting
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="bat --language=sh --style=plain --color=always"

# Use batcat (Ubuntu/Debian package name)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="batcat --language=sh --style=plain --color=always"

# Use highlight
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="highlight --syntax=bash --out-format=ansi"

# Use pygmentize
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="pygmentize -l bash"

# Use plain cat (no syntax highlighting)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="cat"
```

### Configuration Examples

#### Minimal Custom Setup
```bash
# ~/.zshrc
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")
plugins=(... zsh-active-cheatsheet)
```

#### Advanced Custom Setup with Syntax Highlighting
```bash
# ~/.zshrc
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/shell-cheats"
    "$HOME/work/team-cheats"
    "$HOME/.local/share/personal-cheats"
)
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("secrets" "draft" ".backup")
export ZSH_ACTIVE_CHEATSHEET_DEBUG=true
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="bat --language=sh --style=plain --color=always"

plugins=(... zsh-active-cheatsheet)
```

#### Manual Compilation Mode
```bash
# ~/.zshrc
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/slow-network-drive/cheats")
export ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE=false  # Don't slow startup

plugins=(... zsh-active-cheatsheet)

# Manually compile when needed
# zsh-active-cheatsheet-compile
```

#### Different Highlighter Options
```bash
# ~/.zshrc

# Option 1: bat (if installed via Homebrew/most package managers)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="bat --language=sh --style=plain --color=always"

# Option 2: batcat (Ubuntu/Debian package name)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="batcat --language=sh --style=plain --color=always"

# Option 3: highlight package
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="highlight --syntax=bash --out-format=ansi --style=github"

# Option 4: pygmentize (Python package)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="pygmentize -l bash -f terminal"

# Option 5: No highlighting (fastest)
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="cat"

plugins=(... zsh-active-cheatsheet)
```

## Usage

### Manual Compilation

When auto-compilation is disabled or you want to refresh:
```bash
# Compile with current configuration
zsh-active-cheatsheet-compile

# Or run compiler directly with custom options
~/.config/zsh/plugins/zsh-active-cheatsheet/cheats-compiler.sh \
    --ignore temp \
    /path/to/cheats1 \
    /path/to/cheats2
```

### Workflow Examples

#### Example 1: Personal + Work Cheats
```bash
# ~/.zshrc configuration
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/.config/personal-cheats"
    "$HOME/work/team-cheats"
    "$HOME/work/project-specific-cheats"
)
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("confidential" "wip")

plugins=(... zsh-active-cheatsheet)
```

#### Example 2: Dotfiles Integration
```bash
# ~/.zshrc configuration
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/zsh/cheats"
    "$HOME/dotfiles/tmux/cheats"
    "$HOME/dotfiles/vim/cheats"
)

plugins=(... zsh-active-cheatsheet)
```

#### Example 3: Team Shared Cheats
```bash
# ~/.zshrc configuration
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/.config/cheats"              # personal
    "/shared/team/dev-cheats"            # team shared
    "$HOME/projects/current/docs/cheats" # project specific
)
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("draft" "old")

plugins=(... zsh-active-cheatsheet)
```

## Default Configuration

If no configuration is provided, the plugin uses these defaults:

- **Directories**: `~/.config/aliases`, `~/.config/cheats`
- **Auto-compile**: Enabled
- **Debug**: Disabled
- **Highlighter**: `cat` (no syntax highlighting)
- **Ignore patterns**: Built-in defaults (`.git`, `node_modules`, etc.)

## Dependencies

### Required
- `zsh`
- `fzf` - For fuzzy finding interface
- `jq` - For JSON processing

### Optional
- `bat` or `batcat` - For syntax highlighting (can be configured via `ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER`)
- `highlight` - Alternative syntax highlighter
- `pygmentize` - Another syntax highlighter option

## Troubleshooting

### Check Current Configuration
```bash
# Show configured directories
echo $ZSH_ACTIVE_CHEATSHEET_DIRS

# Show ignore patterns
echo $ZSH_ACTIVE_CHEATSHEET_IGNORE

# Check if auto-compile is enabled
echo $ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE

# Check highlighter
echo $ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER
```

### Debug Compilation Issues
```bash
# Enable debug mode temporarily
ZSH_ACTIVE_CHEATSHEET_DEBUG=true zsh-active-cheatsheet-compile

# Or check what directories exist
for dir in "${ZSH_ACTIVE_CHEATSHEET_DIRS[@]}"; do
    echo "Directory: $dir (exists: $([ -d "$dir" ] && echo yes || echo no))"
done
```

### Syntax Highlighting Issues
```bash
# Test if your highlighter works
echo 'echo "test"' | $ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER

# Check if bat/batcat is available
which bat || which batcat || echo "bat not found"

# Fallback to cat if issues
export ZSH_ACTIVE_CHEATSHEET_HIGHLIGHTER="cat"
```

## License

MIT License
