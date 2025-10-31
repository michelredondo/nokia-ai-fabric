#!/usr/bin/env bash
#
# edactl Autocompletion Installation Script
# 
# This script sets up intelligent shell autocompletion for the edactl command.
# It creates a wrapper script and installs completion functions that provide
# kubectl-style command descriptions during tab completion.
#
# Usage: ./edactl-autocompletion.sh [SHELL]
#
# Supported shells:
# - bash        Generate the autocompletion script for bash (default)
# - fish        Generate the autocompletion script for fish
# - powershell  Generate the autocompletion script for powershell
# - zsh         Generate the autocompletion script for zsh
#
# Features:
# - Native cobra completion integration via kubectl exec
# - Command descriptions shown on tab completion (bash/zsh)
# - Consistent display behavior for single and multiple tab presses
# - Support for all edactl commands and flags
#

set -euo pipefail

#
# Configuration
#
SHELL_TYPE="${1:-bash}"  # Default to bash if no argument provided
EDA_NS="eda-system"
EDA_LABEL="eda.nokia.com/app=eda-toolbox"
LOCAL_BIN="$HOME/.local/bin"
EDACTL_WRAPPER="$LOCAL_BIN/edactl"

# Shell-specific configuration
case "$SHELL_TYPE" in
    bash)
        EDA_COMPLETION_FILE="$HOME/.edactl_completion.sh"
        SHELL_CONFIG="$HOME/.bashrc"
        ;;
    zsh)
        EDA_COMPLETION_FILE="$HOME/.edactl_completion.zsh"
        SHELL_CONFIG="$HOME/.zshrc"
        ;;
    fish)
        EDA_COMPLETION_FILE="$HOME/.config/fish/completions/edactl.fish"
        SHELL_CONFIG="$HOME/.config/fish/config.fish"
        ;;
    powershell)
        EDA_COMPLETION_FILE="$HOME/.edactl_completion.ps1"
        SHELL_CONFIG=""  # PowerShell profiles are more complex
        ;;
    *)
        echo "❌ Error: Unsupported shell type '$SHELL_TYPE'"
        echo
        echo "Supported shells:"
        echo "  bash        Generate the autocompletion script for bash"
        echo "  fish        Generate the autocompletion script for fish"
        echo "  powershell  Generate the autocompletion script for powershell"
        echo "  zsh         Generate the autocompletion script for zsh"
        echo
        echo "Usage: $0 [SHELL]"
        exit 1
        ;;
esac

#
# Utility Functions
#

# Print colored status messages
print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

print_success() {
    echo -e "\033[1;32m✅ [SUCCESS]\033[0m $1"
}

# Generate shell-specific completion scripts
generate_bash_completion() {
    cat > "$EDA_COMPLETION_FILE" <<'EOF'
#!/bin/bash
#
# edactl bash completion script
# Provides intelligent autocompletion with descriptions for edactl commands
#

# Ensure bash-completion is loaded
if ! type _init_completion &>/dev/null; then
    [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

#
# Main completion function for edactl
# This function handles all completion logic using native cobra completion
#
_edactl_hybrid_completion() {
    local cur prev words cword
    _init_completion || return

    # Get native completion from edactl using cobra's __complete command
    local cobra_output
    cobra_output=$("$HOME/.local/bin/edactl" __complete "${words[@]:1}" 2>/dev/null)

    # Check if we got valid completion output
    if [[ -n "$cobra_output" ]]; then
        # Filter out cobra directive lines (starting with :) and empty lines
        local filtered_output
        filtered_output=$(echo "$cobra_output" | head -n -1 | grep -v '^:' | grep -v '^$')
        
        if [[ -n "$filtered_output" ]]; then
            # Process completion output and build arrays
            local -a completion_array descriptions_array
            
            # Parse tab-separated completion output (command<TAB>description)
            while IFS=$'\t' read -r cmd desc; do
                # Only include commands that match the current input
                if [[ "$cmd" == "$cur"* ]]; then
                    completion_array+=("$cmd")
                    
                    # Store full line with description for display
                    if [[ -n "$desc" ]]; then
                        descriptions_array+=("$cmd	$desc")
                    else
                        descriptions_array+=("$cmd")
                    fi
                fi
            done <<< "$filtered_output"
            
            # Handle completion based on number of matches
            if [[ ${#completion_array[@]} -gt 0 ]]; then
                
                # Single match: complete the command normally
                if [[ ${#completion_array[@]} -eq 1 ]]; then
                    COMPREPLY=("${completion_array[0]}")
                    
                # Multiple matches: display descriptions and prevent bash column formatting
                else
                    echo  # New line for clean display
                    
                    # Display each command with its description
                    for desc_line in "${descriptions_array[@]}"; do
                        local cmd_part="${desc_line%%$'\t'*}"      # Extract command name
                        local desc_part="${desc_line#*$'\t'}"      # Extract description
                        
                        # Format output: command name (left-aligned) + description
                        if [[ "$desc_part" != "$cmd_part" ]]; then
                            printf "  %-30s %s\n" "$cmd_part" "$desc_part"
                        else
                            printf "  %s\n" "$cmd_part"
                        fi
                    done
                    
                    # Redraw the command line prompt
                    echo -n "${PS1@P}${COMP_LINE}"
                    
                    # Return empty COMPREPLY to prevent bash's default column display
                    # This ensures our custom description display is always shown
                    COMPREPLY=()
                fi
                
                return 0
            fi
        fi
    fi

    # If no completion from cobra, try to suggest flags based on current input
    if [[ "$cur" == -* ]]; then
        # For flag completion, try multiple strategies to get flags
        local flag_output
        
        # Strategy 1: Try with current partial flag
        flag_output=$("$HOME/.local/bin/edactl" __complete "${words[@]:1}" "$cur" 2>/dev/null)
        
        # Strategy 2: If that fails, try getting all flags by adding "--"
        if [[ -z "$flag_output" || ! "$flag_output" =~ "$cur" ]]; then
            flag_output=$("$HOME/.local/bin/edactl" __complete "${words[@]:1}" "--" 2>/dev/null)
        fi
        
        if [[ -n "$flag_output" ]]; then
            local flag_filtered
            flag_filtered=$(echo "$flag_output" | head -n -1 | grep -v '^:' | grep -v '^$' | grep "^$cur")
            
            if [[ -n "$flag_filtered" ]]; then
                local -a flag_completions flag_descriptions
                
                # Parse flag completions with descriptions
                while IFS=$'\t' read -r flag desc; do
                    if [[ "$flag" == "$cur"* ]]; then
                        flag_completions+=("$flag")
                        if [[ -n "$desc" ]]; then
                            flag_descriptions+=("$flag	$desc")
                        else
                            flag_descriptions+=("$flag")
                        fi
                    fi
                done <<< "$flag_filtered"
                
                # Display flags with descriptions if we have multiple matches
                if [[ ${#flag_completions[@]} -gt 1 ]]; then
                    echo  # New line for clean display
                    
                    for desc_line in "${flag_descriptions[@]}"; do
                        local flag_part="${desc_line%%$'\t'*}"
                        local desc_part="${desc_line#*$'\t'}"
                        
                        if [[ "$desc_part" != "$flag_part" ]]; then
                            printf "  %-30s %s\n" "$flag_part" "$desc_part"
                        else
                            printf "  %s\n" "$flag_part"
                        fi
                    done
                    
                    echo -n "${PS1@P}${COMP_LINE}"
                    COMPREPLY=()
                else
                    COMPREPLY=("${flag_completions[@]}")
                fi
                return 0
            fi
        fi
    fi
    
    # Special handling for commands that need required flags
    # If we're at a point where cobra returns no completions but we know the command exists,
    # try to provide helpful flag suggestions
    if [[ ${#words[@]} -gt 3 && "$cur" != -* ]]; then
        # Try to get available flags for this command
        local help_flags
        help_flags=$("$HOME/.local/bin/edactl" __complete "${words[@]:1}" "--" 2>/dev/null)
        
        if [[ -n "$help_flags" ]]; then
            local required_flags
            required_flags=$(echo "$help_flags" | head -n -1 | grep -v '^:' | grep -E "(--from|--to|--name)" | head -5)
            
            if [[ -n "$required_flags" ]]; then
                echo  # New line for clean display
                echo "  💡 Available flags for this command:"
                
                while IFS=$'\t' read -r flag desc; do
                    if [[ -n "$desc" ]]; then
                        printf "  %-30s %s\n" "$flag" "$desc"
                    else
                        printf "  %s\n" "$flag"
                    fi
                done <<< "$required_flags"
                
                echo -n "${PS1@P}${COMP_LINE}"
                COMPREPLY=()
                return 0
            fi
        fi
    fi

    # No completion available - return empty array
    COMPREPLY=()
}

# Register the completion function for edactl command
complete -F _edactl_hybrid_completion edactl
EOF
}

generate_zsh_completion() {
    cat > "$EDA_COMPLETION_FILE" <<'EOF'
#compdef edactl

# edactl zsh completion script
# Provides intelligent autocompletion with descriptions for edactl commands

_edactl() {
    local context state line
    
    # Get completion from edactl
    local cobra_output
    cobra_output=$("$HOME/.local/bin/edactl" __complete "${words[@]:1}" 2>/dev/null)
    
    if [[ -n "$cobra_output" ]]; then
        # Filter out directive lines and process completions
        local filtered_output
        filtered_output=$(echo "$cobra_output" | head -n -1 | grep -v '^:' | grep -v '^$')
        
        if [[ -n "$filtered_output" ]]; then
            local -a completions descriptions
            while IFS=$'\t' read -r cmd desc; do
                if [[ "$cmd" == "${words[CURRENT]}"* ]]; then
                    completions+=("$cmd")
                    if [[ -n "$desc" ]]; then
                        descriptions+=("$cmd:$desc")
                    else
                        descriptions+=("$cmd")
                    fi
                fi
            done <<< "$filtered_output"
            
            if [[ ${#completions[@]} -gt 0 ]]; then
                _describe 'edactl commands' descriptions
                return 0
            fi
        fi
    fi
    
    return 1
}

# Register the completion function for edactl
compdef _edactl edactl
EOF
}

generate_fish_completion() {
    # Create fish completions directory if it doesn't exist
    mkdir -p "$(dirname "$EDA_COMPLETION_FILE")"
    
    cat > "$EDA_COMPLETION_FILE" <<'EOF'
# edactl fish completion script
# Provides intelligent autocompletion for edactl commands

function __edactl_complete
    set -l cobra_output ($HOME/.local/bin/edactl __complete (commandline -opc)[2..] 2>/dev/null)
    
    if test -n "$cobra_output"
        set -l filtered_output (echo "$cobra_output" | head -n -1 | grep -v '^:' | grep -v '^$')
        
        if test -n "$filtered_output"
            echo "$filtered_output" | while read -l cmd desc
                if test -n "$desc"
                    echo "$cmd	$desc"
                else
                    echo "$cmd"
                end
            end
        end
    end
end

complete -c edactl -f -a "(__edactl_complete)"
EOF
}

generate_powershell_completion() {
    cat > "$EDA_COMPLETION_FILE" <<'EOF'
# edactl PowerShell completion script
# Provides intelligent autocompletion for edactl commands

Register-ArgumentCompleter -Native -CommandName edactl -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    
    $cobra_output = & "$env:USERPROFILE\.local\bin\edactl.exe" __complete $wordToComplete 2>$null
    
    if ($cobra_output) {
        $filtered_output = $cobra_output | Where-Object { $_ -notmatch '^:' -and $_ -ne '' } | Select-Object -SkipLast 1
        
        foreach ($line in $filtered_output) {
            $parts = $line -split "`t", 2
            $cmd = $parts[0]
            $desc = if ($parts.Length -gt 1) { $parts[1] } else { "" }
            
            if ($cmd -like "$wordToComplete*") {
                [System.Management.Automation.CompletionResult]::new(
                    $cmd, 
                    $cmd, 
                    'ParameterValue', 
                    $desc
                )
            }
        }
    }
}
EOF
}

#
# Setup Process
#

print_status "Setting up edactl autocompletion for $SHELL_TYPE"

# 1. Create wrapper script directory
mkdir -p "$LOCAL_BIN"

print_status "Creating edactl wrapper script..."

# 2. Create the edactl wrapper that handles both execution and completion
cat > "$EDACTL_WRAPPER" <<'EOF'
#!/bin/bash
#
# edactl wrapper script
# Routes commands to the eda-toolbox pod via kubectl exec
# Handles both normal execution and completion requests
#

# Find the active eda-toolbox pod
get_pod() {
    kubectl -n eda-system get pods -l eda.nokia.com/app=eda-toolbox \
        -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

POD=$(get_pod)
if [[ -z "$POD" ]]; then
    echo "Error: No eda-toolbox pod found" >&2
    exit 1
fi

# Handle completion requests from shell completion system
if [[ "$1" == "__complete" ]]; then
    shift
    kubectl -n eda-system exec "$POD" -- edactl __complete "$@" 2>/dev/null || exit 1
else
    # Execute normal edactl commands interactively
    exec kubectl -n eda-system exec -it "$POD" -- edactl "$@"
fi
EOF

chmod +x "$EDACTL_WRAPPER"
print_status "Wrapper installed at $EDACTL_WRAPPER"

# 3. Ensure ~/.local/bin is in PATH for the wrapper to be accessible
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    if [[ -n "$SHELL_CONFIG" ]] && [[ -f "$SHELL_CONFIG" ]]; then
        if ! grep -q "$LOCAL_BIN" "$SHELL_CONFIG"; then
            case "$SHELL_TYPE" in
                bash|zsh)
                    echo "export PATH=\"$LOCAL_BIN:\$PATH\"" >> "$SHELL_CONFIG"
                    ;;
                fish)
                    echo "set -gx PATH $LOCAL_BIN \$PATH" >> "$SHELL_CONFIG"
                    ;;
            esac
            print_status "Added $LOCAL_BIN to PATH in $SHELL_CONFIG"
        fi
    else
        print_status "⚠️  Please manually add $LOCAL_BIN to your PATH"
    fi
fi

# 4. Generate shell-specific completion script
print_status "Creating $SHELL_TYPE completion function..."

case "$SHELL_TYPE" in
    bash)
        generate_bash_completion
        ;;
    zsh)
        generate_zsh_completion
        ;;
    fish)
        generate_fish_completion
        ;;
    powershell)
        generate_powershell_completion
        ;;
esac

print_status "Completion function saved to $EDA_COMPLETION_FILE"

# 5. Configure shell to load the completion script automatically
case "$SHELL_TYPE" in
    bash|zsh)
        if [[ -n "$SHELL_CONFIG" ]] && [[ -f "$SHELL_CONFIG" ]]; then
            if ! grep -q "source $EDA_COMPLETION_FILE" "$SHELL_CONFIG"; then
                echo "source $EDA_COMPLETION_FILE" >> "$SHELL_CONFIG"
                print_status "Added autocompletion source line to $SHELL_CONFIG"
            else
                print_status "Autocompletion source already in $SHELL_CONFIG"
            fi
        fi
        ;;
    fish)
        # Fish automatically loads completions from ~/.config/fish/completions/
        print_status "Fish will automatically load completions from the completions directory"
        ;;
    powershell)
        print_status "PowerShell completion script created. Add to your PowerShell profile manually:"
        print_status "  . $EDA_COMPLETION_FILE"
        ;;
esac

#
# Installation Complete
#
echo
print_success "edactl autocompletion installation complete for $SHELL_TYPE!"
echo

case "$SHELL_TYPE" in
    bash)
        echo "📋 Next steps:"
        echo "   1. Run: source ~/.bashrc"
        echo "   2. Test with: edactl get <TAB>"
        echo "   3. Try multiple TABs for consistent description display"
        ;;
    zsh)
        echo "📋 Next steps:"
        echo "   1. Run: source ~/.zshrc"
        echo "   2. Test with: edactl get <TAB>"
        echo "   3. Descriptions will show in zsh completion menu"
        ;;
    fish)
        echo "📋 Next steps:"
        echo "   1. Restart fish or run: source ~/.config/fish/config.fish"
        echo "   2. Test with: edactl get <TAB>"
        echo "   3. Fish will show completions with descriptions"
        ;;
    powershell)
        echo "📋 Next steps:"
        echo "   1. Add this line to your PowerShell profile:"
        echo "      . $EDA_COMPLETION_FILE"
        echo "   2. Restart PowerShell"
        echo "   3. Test with: edactl get <TAB>"
        ;;
esac

echo
echo "💡 Features enabled:"
echo "   • Native cobra completion support"
echo "   • Command and flag completions"
case "$SHELL_TYPE" in
    bash|zsh)
        echo "   • kubectl-style command descriptions"
        echo "   • Consistent display behavior"
        ;;
    fish)
        echo "   • Fish-style completion with descriptions"
        ;;
    powershell)
        echo "   • PowerShell-style completion with tooltips"
        ;;
esac
