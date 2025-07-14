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

# 2. Configure (directories to scan, optional)
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# 3. Source the plugin file (not the core file)
source ~/.config/zsh/plugins/zsh-active-cheatsheet/zsh-active-cheatsheet.plugin.zsh
```

### Using Oh-My-Zsh

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

Configure the plugin by setting these variables in your `.zshenv` or `.zshrc` **before** loading the plugin:

#### `ZSH_ACTIVE_CHEATSHEET_DIRS`
**Default**: `("$HOME/.config/aliases" "$HOME/.config/cheats")`

Directories to scan for cheat files:

```bash
# Single directory
export ZSH_ACTIVE_CHEATSHEET_DIRS=("$HOME/my-cheats")

# Multiple directories
export ZSH_ACTIVE_CHEATSHEET_DIRS=(
    "$HOME/dotfiles/cheats"
    "$HOME/.config"
    "$HOME/.local/share/cheats"
)
```

#### `ZSH_ACTIVE_CHEATSHEET_IGNORE`
**Default**: `("git", "cache", "plugins", "backup", "log")`

Additional patterns to ignore (beyond built-in defaults):

```bash
# Ignore specific directories
export ZSH_ACTIVE_CHEATSHEET_IGNORE=(
    "node_modules"
    "dist"
    "backup"
    "git"
)
```

#### `ZSH_ACTIVE_CHEATSHEET_AUTO_COMPILE`
**Default**: `true`

Enable/disable automatic compilation (scanning directories and building the common cheats file) on ZSH startup:

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
```

### Default Configuration

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


## Creating Cheat Files

The plugin scans your configured directories for blocks of cheats metadata using a simple format. Cheats can be embedded in existing configuration files (like `.zshrc`, `.tmux.conf`, or alias files) as comments, or created in dedicated cheat files.

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
- **Executable**: `yes` if it can run when selected, `no` for reference only

### Optional Fields

- **Description**: Detailed explanation of what the command does
- **Short**: Brief one-line summary
- **Example**: Usage example or sample output

### Pipe Patterns
You create a cheat for multiple similar triggers using pipe patterns (`(string | string)`). This allows to create only one set of metadata for multiple triggers (like aliases or keybindings) that will be split up in to multiple cheat entries during compilation. The pipe pattern can be used in multiple cheat properties like `Trigger`, `Function`, and `Description` in order to highlight the differences between the triggers.

```bash
# Cheat
# Type        alias
# Trigger     (l | ll)
# Domain      shell
# Conditional no
# Alternative None
# Function    lsd (-1 | -l)
# Description Lists non-hidden files and folder in the directory
# Example     (l | ll)  + <Enter> -> outputs (simple | detailed) list of non-hidden items
# Short       List non-hidden items
# Executable  yes
alias l='lsd -1'
alias ll='lsd -l'
```

### Placeholders

You can use placeholders (`<user-input>`) in the `Function` field to allow interactive editing when executing the command. This is useful for commands that require user input, like file paths or options.

```bash
# Cheat
# Type         alias
# Trigger      dlogs
# Domain       docker
# Conditional  no
# Function     docker logs -f <container_name>
# Executable   yes
# Description  Follow logs for a Docker container (interactive container name)
# Short        Docker logs (follow)
alias dlogs='docker logs -f'
```

### Examples

#### Embedded in .zshrc file

```bash
# Your existing .zshrc content
export PATH="/usr/local/bin:$PATH"

# Cheat
# Type         alias
# Trigger      la
# Domain       shell
# Function     ls -la
# Executable   yes
# Description  List all files including hidden ones in long format
# Short        List all files (long format)
alias la='ls -la'

# Cheat
# Type         function
# Trigger      mkcd
# Domain       shell
# Function     mkdir -p "$1" && cd "$1"
# Executable   yes
# Description  Create directory and change into it
# Short        Make and change directory
# Example      mkcd new-project
mkcd() {
    mkdir -p "$1" && cd "$1"
}
```

#### Embedded in .tmux.conf file

```bash
# Your existing tmux config
set -g mouse on

# Cheat
# Type         bindkey
# Trigger      Ctrl+a c
# Domain       tmux
# Function     new-window
# Executable   no
# Description  Create a new tmux window
# Short        New window
bind c new-window

# Cheat
# Type         bindkey
# Trigger      Ctrl+a |
# Domain       tmux
# Function     split-window -h
# Executable   yes
# Description  Split current pane horizontally
# Short        Horizontal split
bind | split-window -h
```

#### Dedicated cheat file

Create `~/.config/cheats/misc`:

```bash
# Cheat
Trigger      Ctrl + a
Type         bindkey
Domain       shell
Conditional  no
Alternative  Home
Function     beginning-of-line
Description  Move cursor (|) to beginning of command line.
Example      echo | test → <Ctrl+E> → | echo test
Short        Move to line start
Executable   no

# Cheat
Trigger      Ctrl + l
Type         bindkey
Domain       shell
Conditional  no
Alternative  clear (cmd)
Function     clear-screen
Description  Clears the screen like `clear`.
Example      <Ctrl+L> → screen is cleared
Short        Clear screen
Executable   yes

# Cheat
Trigger      Ctrl + r
Type         bindkey
Domain       shell (fzf)
Conditional  no
Alternative  None
Function     history-incremental-search-backward
Description  Interactive reverse fuzzy search in history using FZF.
Example      echo | → <Ctrl+R> → shows previous that includes 'echo'
Short        Fuzzy search history
Executable   yes
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

Better yet, make it an alias in your `.zshrc`:

```bash
alias mkcheats='~/.config/zsh/plugins/zsh-active-cheatsheet/cheats-compiler.sh /path/to/cheats1 /path/to/cheats2'
```
