# Setup Script Documentation

This directory contains an automated setup script (`setup.sh`) for installing and validating a complete Python development environment with UV and VS Code.

## Quick Start

```bash
# Make the script executable (if not already)
chmod +x setup.sh

# Run the setup (installs only what's missing)
./setup.sh

# Or upgrade all tools to latest versions
./setup.sh --upgrade
```

## What Does It Install?

The setup script installs and configures:

1. **Homebrew** - macOS package manager (if not installed)
2. **Python 3** - Latest Python via Homebrew
3. **pip** - Python package installer
4. **UV** - Fast Python package and project manager
5. **VS Code** - Visual Studio Code editor
6. **VS Code Extensions**:
   - Python (ms-python.python)
   - Ruff (charliermarsh.ruff)
7. **Ruff** - Fast Python linter and formatter

## Features

### ✅ Smart Installation
- Only installs tools that are missing
- Uses Homebrew whenever possible for easy upgrades
- Falls back to pip if Homebrew is unavailable
- Checks for existing installations before proceeding

### 🔄 Upgrade Mode
- `./setup.sh --upgrade` upgrades all tools to their latest versions
- Safely skips tools not installed via package managers

### 🎯 Validation
- Validates all installations after setup
- Shows clear status for each tool
- Provides helpful suggestions for fixing issues
- Categorizes tools as critical or optional

### 📦 Project Setup
- Detects if you're in a Python project
- Creates virtual environment if needed
- Syncs dependencies in upgrade mode

## Usage

### Install Mode (Default)

```bash
./setup.sh
```

This mode:
- Installs only missing tools
- Does not modify existing installations
- Validates everything at the end

### Upgrade Mode

```bash
./setup.sh --upgrade
```

This mode:
- Updates Homebrew packages to latest versions
- Upgrades pip to latest version
- Upgrades UV, Ruff, and VS Code
- Syncs project dependencies if in a project
- Validates everything at the end

### Help

```bash
./setup.sh --help
```

Shows usage information and available options.

## Output Examples

### Successful Installation

```
============================================================
🚀 Python Development Environment Setup
============================================================
Running in INSTALL mode - will only install missing tools

============================================================
📦 Installation Phase
============================================================
▶ Checking Homebrew...
✅ Homebrew is already installed

▶ Checking Python...
✅ Python is already installed: Python 3.12.0

▶ Checking pip...
✅ pip is already installed: version 24.0

▶ Checking UV...
✅ UV is already installed: uv 0.4.0

▶ Checking VS Code...
✅ VS Code is already installed: version 1.95.0

▶ Checking VS Code Extensions...
✅ Python extension is already installed
✅ Ruff extension is already installed

▶ Checking Ruff...
✅ Ruff is installed in project: ruff 0.7.0

============================================================
✅ Validation Phase
============================================================
▶ Validating Python...
✅ Python 3.12.0

▶ Validating pip...
✅ pip version 24.0

▶ Validating UV...
✅ uv 0.4.0

▶ Validating VS Code...
✅ VS Code version 1.95.0

▶ Validating VS Code Extensions...
✅ Python extension installed
✅ Ruff extension installed

▶ Validating Ruff...
✅ Ruff (project): ruff 0.7.0

============================================================
📊 Summary
============================================================
Critical tools: 3/3 ✅
Optional tools: 4/4 ✅

✅ All critical tools are installed! You're ready to start.
```

## Requirements

- macOS (the script is designed for macOS)
- Internet connection
- Bash shell (default on macOS)

## What Gets Installed Where?

| Tool | Installation Method | Location |
|------|-------------------|----------|
| Homebrew | Official installer | `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel) |
| Python | Homebrew | `/opt/homebrew/bin/python3` |
| pip | Python module | Bundled with Python |
| UV | Homebrew | `/opt/homebrew/bin/uv` |
| VS Code | Homebrew Cask | `/Applications/Visual Studio Code.app` |
| Ruff | Homebrew or project | `/opt/homebrew/bin/ruff` or `.venv/` |

## Troubleshooting

### "code command not found" after installing VS Code

Even after installation, you may need to add the `code` command to PATH:

1. Open VS Code
2. Press `Cmd+Shift+P`
3. Type "Shell Command: Install 'code' command in PATH"
4. Select it and run

### Script fails with "Permission denied"

Make sure the script is executable:

```bash
chmod +x setup.sh
```

### Homebrew installation fails

The script will attempt to install Homebrew automatically. If it fails:

1. Visit https://brew.sh
2. Follow the manual installation instructions
3. Run the setup script again

### Want to see what would happen without installing?

You can review the script first:

```bash
cat setup.sh
```

Or use the Python validation script to check what's missing:

```bash
python3 validate_setup.py
```

## Related Files

- `PYTHON_PROJECT_SETUP.md` - Complete manual setup guide
- `validate_setup.py` - Python-based validation script (alternative)

## Upgrading in the Future

To keep your tools up-to-date:

```bash
# Upgrade everything
./setup.sh --upgrade

# Or upgrade individual tools via Homebrew
brew upgrade python3 uv ruff
brew upgrade --cask visual-studio-code
```

## Contributing

If you encounter issues or have suggestions for improving the setup script, please:

1. Check the troubleshooting section above
2. Review the manual setup guide in `PYTHON_PROJECT_SETUP.md`
3. Open an issue with details about your environment and error messages

---

**Note**: This setup script is designed for macOS. For Linux or Windows, please refer to the manual installation steps in `PYTHON_PROJECT_SETUP.md`.
