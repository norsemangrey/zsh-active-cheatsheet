# zsh-active-cheatsheet

Interactive cheat sheet browser for zsh using FZF. Press `Ctrl+S` to browse and execute commands from your personal cheat collection.

## Installation

### Using Oh My Zsh

1. Clone to your Oh My Zsh custom plugins directory:
```bash
git clone https://github.com/yourusername/zsh-active-cheatsheet.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-active-cheatsheet
```

2. **Configure the plugin** (optional) in your `~/.zshrc` BEFORE the plugins line:
```bash
# Custom cheat directories
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/cheats"
    "$HOME/work/documentation"
    "$HOME/.config/aliases"
)

# Additional ignore patterns
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("secret" "private" ".env")

# Disable auto-compilation on startup (run manually)
export ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE=false

# Enable debug mode
export ZSH_ACTIVE_CHEATSHEET_DEBUG=true
```

3. Add to your plugins list in `~/.zshrc`:
```bash
plugins=(... zsh-active-cheatsheet)
```

### Using Zinit

```bash
# Configure before loading (optional)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats" "$HOME/.config/aliases")

zinit load "yourusername/zsh-active-cheatsheet"
```

### Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/zsh-active-cheatsheet.git ~/.zsh-plugins/zsh-active-cheatsheet

# 2. Configure in ~/.zshrc (optional)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# 3. Source the plugin
source ~/.zsh-plugins/zsh-active-cheatsheet/zsh-active-cheatsheet.plugin.zsh
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

### Configuration Examples

#### Minimal Custom Setup
```bash
# ~/.zshrc
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")
plugins=(... zsh-active-cheatsheet)
```

#### Advanced Custom Setup
```bash
# ~/.zshrc
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/shell-cheats"
    "$HOME/work/team-cheats"
    "$HOME/.local/share/personal-cheats"
)
export ZSH_ACTIVE_CHEATSHEET_IGNORE=("secrets" "draft" ".backup")
export ZSH_ACTIVE_CHEATSHEET_DEBUG=true

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

## Usage

### Manual Compilation

When auto-compilation is disabled or you want to refresh:
```bash
# Compile with current configuration
zsh-active-cheatsheet-compile

# Or run compiler directly with custom options
~/.zsh-plugins/zsh-active-cheatsheet/cheats-compiler.sh \
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
- **Ignore patterns**: Built-in defaults (`.git`, `node_modules`, etc.)

## Troubleshooting

### Check Current Configuration
```bash
# Show configured directories
echo $ZSH_ACTIVE_CHEATSHEET_DIRS

# Show ignore patterns
echo $ZSH_ACTIVE_CHEATSHEET_IGNORE

# Check if auto-compile is enabled
echo $ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE
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

## License

MIT License
