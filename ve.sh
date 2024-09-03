#!/bin/bash
#ver:1.0.0

DEBUG=0

debug_log() {
    if [ $DEBUG -eq 1 ]; then
        echo "Debug: $1" >&2
    fi
}

# Function to find virtual environment
find_virtual_env() {
    local dir="$1"
    local env_name=""
    local env_path=""
    local activate_path=""

    debug_log "Starting search from directory: $dir"

    while [ "$dir" != "/" ]; do
        debug_log "Searching in directory: $dir"

        # Search for venv environments
        local venv_activate=$(find "$dir" -maxdepth 3 -type f \( -path "*/bin/activate" -o -path "*/Scripts/activate" \) -print -quit 2>/dev/null)
        
        # Search for conda environments
        local conda_env_yml=$(find "$dir" -maxdepth 2 -type f -name "environment.yml" -print -quit 2>/dev/null)
        local conda_activate=$(find "$dir" -maxdepth 3 -type f \( -path "*/etc/profile.d/conda.sh" -o -path "*/conda.exe" \) -print -quit 2>/dev/null)
        
        debug_log "venv_activate = $venv_activate"
        debug_log "conda_env_yml = $conda_env_yml"
        debug_log "conda_activate = $conda_activate"

        if [ -n "$venv_activate" ]; then
            env_name="venv"
            env_path=$(dirname $(dirname "$venv_activate"))
            activate_path="$venv_activate"
            debug_log "Found venv environment at $env_path"
            debug_log "Activate script: $activate_path"
            break
        elif [ -n "$conda_env_yml" ]; then
            env_name="conda"
            env_path=$(dirname "$conda_env_yml")
            activate_path=$(dirname "$conda_env_yml")/bin/activate
            debug_log "Found conda environment (yml) at $env_path"
            debug_log "Activate script: $activate_path"
            break
        elif [ -n "$conda_activate" ]; then
            env_name="conda"
            if [[ "$conda_activate" == *"conda.exe" ]]; then
                env_path=$(dirname $(dirname "$conda_activate"))
            else
                env_path=$(dirname $(dirname $(dirname "$conda_activate")))
            fi
            activate_path="$conda_activate"
            debug_log "Found conda environment at $env_path"
            debug_log "Activate script: $activate_path"
            break
        fi

        dir=$(dirname "$dir")
    done

    debug_log "Search completed. env_name = $env_name, env_path = $env_path, activate_path = $activate_path"

    echo "$env_name:$env_path:$activate_path"
}

# Function to toggle virtual environment activation/deactivation
toggle_virtual_env() {
    local action=$1
    local current_dir=$(pwd)
    debug_log "Current directory: $current_dir"
    
    local env_info=$(find_virtual_env "$current_dir")
    debug_log "Environment info: $env_info"
    
    local env_name=$(echo $env_info | cut -d':' -f1)
    local env_path=$(echo $env_info | cut -d':' -f2)
    local activate_path=$(echo $env_info | cut -d':' -f3)

    debug_log "env_name = $env_name, env_path = $env_path, activate_path = $activate_path"

    if [ "$action" == "act" ]; then
        if [ -z "$env_name" ]; then
            echo "No virtual environment found in the current directory or its parents" >&2
            return 1
        elif [ "$env_name" == "venv" ]; then
            if [ -f "$activate_path" ]; then
                echo "Activating venv environment: $env_path"
                source "$activate_path"
                echo "Venv environment activated. Use 've deact' to deactivate."
            else
                echo "Error: Activation script not found at $activate_path" >&2
                return 1
            fi
        elif [ "$env_name" == "conda" ]; then
            if command -v conda &> /dev/null; then
                echo "Activating conda environment: $env_path"
                local env_name=$(basename "$env_path")
                source "$(conda info --base)/etc/profile.d/conda.sh"
                conda activate "$env_name"
                echo "Conda environment activated. Use 've deact' to deactivate."
            else
                echo "Error: conda command not found. Is Conda installed and initialized?" >&2
                return 1
            fi
        fi
    elif [ "$action" == "deact" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
            echo "Venv environment deactivated."
        elif [ -n "$CONDA_PREFIX" ]; then
            conda deactivate
            echo "Conda environment deactivated."
        else
            echo "No active virtual environment found."
            return 1
        fi
    else
        echo "Invalid action. Use 'act' to activate or 'deact' to deactivate." >&2
        return 1
    fi
}

# Main processing
if [ "$1" == "--help" ]; then
    show_help
elif [ "$1" == "--debug" ]; then
    DEBUG=1
    shift
    toggle_virtual_env $1
elif [ "$1" == "act" ] || [ "$1" == "deact" ]; then
    toggle_virtual_env $1
else
    echo "Usage: ve {act|deact|--help} [--debug]" >&2
    exit 1
fi