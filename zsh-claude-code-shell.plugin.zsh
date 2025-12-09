# zsh-claude-code-shell - Generate shell commands from natural language using Claude Code
# Usage: Type "# <description>" and press Enter to generate a command

# Configuration
: ${ZSH_CLAUDE_SHELL_DISABLED:=0}
: ${ZSH_CLAUDE_SHELL_MODEL:=}
: ${ZSH_CLAUDE_SHELL_DEBUG:=0}

# Check if claude CLI is available (lazy check - deferred until first use)
_zsh_claude_check_cli() {
    if ! command -v claude &> /dev/null; then
        echo "zsh-claude-code-shell: 'claude' command not found. Please install Claude Code CLI."
        return 1
    fi
    return 0
}

# Sanitize output - remove markdown code blocks and trim whitespace
_zsh_claude_sanitize() {
    local input="$1"

    # Remove markdown code block markers (```bash, ```, etc.)
    input="${input#\`\`\`*$'\n'}"  # Remove opening ```lang\n
    input="${input%\`\`\`}"         # Remove closing ```
    input="${input#\`\`\`}"         # Remove opening ``` without newline

    # Remove single backticks wrapping the whole command
    if [[ "$input" == \`*\` ]]; then
        input="${input#\`}"
        input="${input%\`}"
    fi

    # Trim leading/trailing whitespace
    input="${input#"${input%%[![:space:]]*}"}"
    input="${input%"${input##*[![:space:]]}"}"

    echo "$input"
}

# Main widget that intercepts Enter key
_zsh_claude_accept_line() {
    # Pass through if disabled
    if [[ "$ZSH_CLAUDE_SHELL_DISABLED" == "1" ]]; then
        zle .accept-line
        return
    fi

    # Pass through if buffer doesn't start with "# "
    if [[ ! "$BUFFER" =~ ^'# ' ]]; then
        zle .accept-line
        return
    fi

    # Pass through multi-line buffers
    if [[ "$BUFFER" == *$'\n'* ]]; then
        zle .accept-line
        return
    fi

    # Extract query (remove "# " prefix)
    local query="${BUFFER:2}"

    # Skip empty queries
    if [[ -z "${query// }" ]]; then
        zle .accept-line
        return
    fi

    # Check if claude CLI is available
    if ! _zsh_claude_check_cli; then
        zle reset-prompt
        return 1
    fi

    # Show loading message
    zle -R "Generating command with Claude..."

    # Build claude command - restrict tools and use focused system prompt
    local claude_args=("-p" "--output-format" "text")
    claude_args+=("--tools" "WebSearch,WebFetch")
    claude_args+=("--system-prompt" "You are a shell command generator. Your ONLY job is to output a single shell command that accomplishes the user's request. Output ONLY the raw shell command - no markdown, no code blocks, no explanations, no comments, no backticks. Just the executable command itself on a single line. If you need to look up command syntax, you may use web search.")

    if [[ -n "$ZSH_CLAUDE_SHELL_MODEL" ]]; then
        claude_args+=("--model" "$ZSH_CLAUDE_SHELL_MODEL")
    fi

    # Call Claude Code CLI with just the query as prompt
    local cmd
    local exit_code

    if [[ "$ZSH_CLAUDE_SHELL_DEBUG" == "1" ]]; then
        cmd=$(claude "${claude_args[@]}" "$query" 2>&1)
        exit_code=$?
    else
        cmd=$(claude "${claude_args[@]}" "$query" 2>/dev/null)
        exit_code=$?
    fi

    # Handle errors
    if [[ $exit_code -ne 0 ]] || [[ -z "$cmd" ]]; then
        zle -M "Error: Failed to generate command (exit code: $exit_code)"
        zle reset-prompt
        return 1
    fi

    # Sanitize the output
    cmd=$(_zsh_claude_sanitize "$cmd")

    # Replace buffer with generated command
    BUFFER="$cmd"
    CURSOR=${#BUFFER}

    zle reset-prompt
}

# Initialize the plugin
_zsh_claude_init() {
    zle -N accept-line _zsh_claude_accept_line
}

_zsh_claude_init
