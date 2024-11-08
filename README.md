# Virtual Environment Management Script (ve)

## Version

1.0.0

## Overview

The `ve` script is a command-line tool designed to simplify the management of Python virtual environments (venv) and Conda environments. It allows for easy activation of the nearest virtual environment and deactivation of all active virtual environments.

## Features

- Automatically detects and activates the nearest virtual environment (venv or Conda)
- Deactivates all active virtual environments at once
- Supports multiple nested virtual environments
- Provides detailed error handling and logging
- Includes a debug mode for troubleshooting
- Includes a help option for quick reference

## Installation

1. Clone this repository:

```bash
git clone https://github.com/[your-username]/[your-repo-name].git
cd [your-repo-name]
```

2. Make the script executable:

```bash
chmod +x ve.sh
```

3. Move the script to a directory in your PATH (e.g., ~/.local/bin):

```bash
mkdir -p ~/.local/bin
mv ve.sh ~/.local/bin/ve
```

4. Ensure `~/.local/bin` is in your PATH. Add the following line to your `~/.bashrc` (or your shell's configuration file) if it's not already there:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

5. Add the following function to your `~/.bashrc` (or your shell's configuration file):

```bash
ve() {
    case "$1" in
        act|deact)
            source ~/.local/bin/ve "$@"
            ;;
        *)
            ~/.local/bin/ve "$@"
            ;;
    esac
}
```

6. Reload your shell configuration:

```bash
source ~/.bashrc
```

7. Rename ve files

Change the file name from "ve.sh" to "ve" (Just remove .sh).

The `ve` command should now be globally available.

## Usage

### Activate a Virtual Environment

To activate the nearest virtual environment in the current or parent directories:

```bash
ve act
```

### Deactivate All Virtual Environments

To deactivate all active virtual environments:

```bash
ve deact
```

### Debug Mode

To run the script in debug mode, which provides additional information:

```bash
ve --debug act
ve --debug deact
```

### Display Help

To show usage instructions and options:

```bash
ve --help
```

## Notes

- This script runs in bash. Adjustments may be needed for other shells.
- The script handles nested virtual environments and will activate the nearest one.
- For Conda environments, ensure Conda is properly installed and initialized.

## Troubleshooting

- If the script doesn't work, verify that `~/.local/bin` is in your PATH.
- For permission issues, run `chmod +x ~/.local/bin/ve` to ensure the script is executable.
- For Conda environment issues, check if `conda init` has been properly executed.
- Use the debug mode (`ve --debug act` or `ve --debug deact`) to get more information about what the script is doing.

## Contributing

Please use the GitHub Issue tracker for bug reports and feature requests. Pull requests are welcome.

## License

This script is released under the [MIT License](LICENSE).