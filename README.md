# zsh-active-cheatsheet

Interactive cheat sheet browser for zsh using FZF. Press `Ctrl+S` to browse and execute commands from your personal cheat collection.

![image](https://github.com/user-attachments/assets/3f717149-fe13-4740-b80f-84db5681bb21)

- 🔍 **Instant search** - Press `Ctrl+S` to browse all your cheats with fuzzy finding
- ⚡ **Smart execution** - Run commands directly or edit placeholders interactively
- 🎨 **Syntax highlighting** - Configurable preview with bat/highlight support
- 📁 **Auto-discovery** - Scans your configured directories automatically
- 🔧 **Configurable** - Custom directories, ignore patterns, and highlighters

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

## Creating Cheat Files

The plugin scans your configured directories for cheat blocks using a simple format. Cheats can be embedded in existing configuration files (like `.zshrc`, `.tmux.conf`, or alias files) as comments, or created in dedicated cheat files.

### Cheat Format

Each cheat starts with `# Cheat` and contains metadata fields:

```bash
# Cheat
Type         alias
Trigger      ll
Domain       shell
Function     ls -la
Executable   yes
Description  List files in long format including hidden files
Short        Long list with hidden files
```

### Required Fields

- **Type**: Category of the cheat (alias, function, bindkey, etc.)
- **Trigger**: What activates this command (keyboard shortcut, alias name, etc.)
- **Domain**: Context where it's used (shell, tmux, vim, etc.)
- **Function**: The actual command or code to execute
- **Executable**: `yes` if it should run when selected, `no` for reference only

### Optional Fields

- **Description**: Detailed explanation of what the command does
- **Short**: Brief one-line summary
- **Example**: Usage example or sample output

### Examples

#### Embedded in .zshrc file
```bash
# Your existing .zshrc content
export PATH="/usr/local/bin:$PATH"

# Cheat
Type         alias
Trigger      la
Domain       shell
Function     ls -la
Executable   yes
Description  List all files including hidden ones in long format
Short        List all files (long format)

alias la='ls -la'

# Cheat
Type         function
Trigger      mkcd
Domain       shell
Function     mkdir -p "$1" && cd "$1"
Executable   yes
Description  Create directory and change into it
Short        Make and change directory
Example      mkcd new-project

mkcd() {
    mkdir -p "$1" && cd "$1"
}
```

#### Embedded in .tmux.conf file
```bash
# Your existing tmux config
set -g mouse on

# Cheat
Type         bindkey
Trigger      Ctrl+a c
Domain       tmux
Function     new-window
Executable   no
Description  Create a new tmux window
Short        New window

bind c new-window

# Cheat
Type         bindkey
Trigger      Ctrl+a |
Domain       tmux
Function     split-window -h
Executable   yes
Description  Split current pane horizontally
Short        Horizontal split

bind | split-window -h
```

#### Dedicated cheat file
Create `~/.config/cheats/git-commands.txt`:
```bash
# Git Commands Cheat Sheet

# Cheat
Type         command
Trigger      git-undo
Domain       git
Function     git reset --soft HEAD~1
Executable   yes
Description  Undo last commit but keep changes staged
Short        Undo last commit (soft)

# Cheat
Type         command
Trigger      git-branch-clean
Domain       git
Function     git branch --merged | grep -v "\*\|main\|master" | xargs -n 1 git branch -d
Executable   yes
Description  Delete all merged branches except main/master
Short        Clean merged branches

# Cheat
Type         alias
Trigger      gst
Domain       git
Function     git status --short
Executable   yes
Description  Show git status in short format
Short        Git status (short)
```

#### Multiple alternatives with pipe patterns
```bash
# Cheat
Type         bindkey
Trigger      (Ctrl+a h | Ctrl+a Left)
Domain       tmux
Function     select-pane -L
Executable   yes
Description  Move to left pane
Short        Move left

# This creates two entries:
# 1. Trigger: "Ctrl+a h", Function: "select-pane -L"
# 2. Trigger: "Ctrl+a Left", Function: "select-pane -L"
```

#### Reference-only cheats
```bash
# Cheat
Type         reference
Trigger      docker-logs
Domain       docker
Function     docker logs -f <container_name>
Executable   no
Description  Follow logs for a Docker container
Short        Follow container logs
Example      docker logs -f my-app
```

### File Organization

**Option 1: Mixed with existing files**
- Add cheats as comments in `.zshrc`, `.tmux.conf`, etc.
- Keeps related commands near their definitions

**Option 2: Dedicated cheat files**
- Create separate files in your cheat directories
- Better for large collections or shared team cheats
- Use `.txt` or `.md` extensions

**Option 3: Organized by category**
```
~/.config/cheats/
├── git-commands.txt
├── docker-commands.txt
├── kubernetes.txt
├── shell-aliases.txt
└── tmux-bindings.txt
```

The compiler automatically finds and processes all cheat blocks regardless of file type or location within your configured directories.

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
