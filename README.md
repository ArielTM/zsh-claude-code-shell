# zsh-claude-code-shell

An oh-my-zsh plugin that translates natural language comments into shell commands using [Claude Code](https://claude.ai/claude-code).

## Demo

```bash
# find all js files larger than 100kb modified in the last week and show their sizes
```
Press Enter, and the line becomes:
```bash
find . -name "*.js" -size +100k -mtime -7 -exec ls -lh {} \;
```
Review the command, press Enter again to execute.

Another example:
```bash
# recursively find and delete all node_modules folders
```
Becomes:
```bash
find . -type d -name "node_modules" -prune -exec rm -rf {} +
```

## Prerequisites

- [Claude Code CLI](https://claude.ai/claude-code) installed and authenticated
- zsh shell
- [oh-my-zsh](https://ohmyz.sh/) (optional, for easiest installation)

## Installation

### oh-my-zsh

Clone to your custom plugins directory:

```bash
git clone https://github.com/ArielTM/zsh-claude-code-shell ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-claude-code-shell
```

Add to your `~/.zshrc`:

```bash
plugins=(... zsh-claude-code-shell)
```

Restart your shell or run `source ~/.zshrc`.

### Manual

Clone the repository and source the plugin:

```bash
git clone https://github.com/ArielTM/zsh-claude-code-shell ~/zsh-claude-code-shell
echo 'source ~/zsh-claude-code-shell/zsh-claude-code-shell.plugin.zsh' >> ~/.zshrc
```

### Sheldon

Add to your `~/.config/sheldon/plugins.toml`:

```toml
[plugins.zsh-claude-code-shell]
github = "ArielTM/zsh-claude-code-shell"
```

Then apply:

```bash
sheldon lock && sheldon source >> ~/.zshrc
```

Or if you're already sourcing sheldon in your `~/.zshrc` (e.g. `eval "$(sheldon source)"`), just run `sheldon lock`.

### zinit

```bash
zinit light ArielTM/zsh-claude-code-shell
```

### zplug

```bash
zplug "ArielTM/zsh-claude-code-shell"
```

## Usage

1. Type a comment starting with `# ` followed by what you want to do
2. Press Enter
3. The comment is replaced with the generated command
4. Review the command, press Enter to execute (or edit it first)

### Examples

```bash
# find all TODO comments in typescript files
# becomes: grep -rn "TODO" --include="*.ts" .

# show top 10 largest files in current directory recursively
# becomes: find . -type f -exec du -h {} + | sort -rh | head -10

# kill all processes matching "node"
# becomes: pkill -f node

# compress all log files older than 30 days
# becomes: find . -name "*.log" -mtime +30 -exec gzip {} \;

# show git commits from last week with stats
# becomes: git log --since="1 week ago" --stat

# find duplicate files by md5 hash
# becomes: find . -type f -exec md5sum {} + | sort | uniq -w32 -dD
```

## Configuration

Set these environment variables in your `~/.zshrc` before the plugin loads:

| Variable | Default | Description |
|----------|---------|-------------|
| `ZSH_CLAUDE_SHELL_DISABLED` | `0` | Set to `1` to disable the plugin |
| `ZSH_CLAUDE_SHELL_MODEL` | (default) | Override the Claude model (e.g., `sonnet`, `opus`) |
| `ZSH_CLAUDE_SHELL_DEBUG` | `0` | Set to `1` to show debug output |
| `ZSH_CLAUDE_SHELL_FANCY_LOADING` | `1` | Set to `0` to use simple loading message instead of animated spinner |

### Example

```bash
# Use a specific model
export ZSH_CLAUDE_SHELL_MODEL="sonnet"

# Temporarily disable
export ZSH_CLAUDE_SHELL_DISABLED=1
```

## How It Works

The plugin overrides zsh's `accept-line` widget (the Enter key handler). When you press Enter:

1. If the line starts with `# `, it extracts your description
2. Calls `claude -p` with your description
3. Replaces the buffer with the generated command
4. You review and press Enter again to execute

Lines that don't start with `# ` work normally.

## License

MIT
