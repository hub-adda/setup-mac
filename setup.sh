#!/usr/bin/env bash
###############################################################################
# Python Development Environment Setup Script
# 
# This script installs and validates all required tools for Python development
# with UV and VS Code. It uses Homebrew when possible for easy upgrades.
#
# Usage:
#   ./setup.sh           # Install missing tools only
#   ./setup.sh --upgrade # Upgrade existing tools to latest versions
#   ./setup.sh --help    # Show help message
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
UPGRADE_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --upgrade)
            UPGRADE_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --upgrade    Upgrade existing tools to latest versions"
            echo "  --help, -h   Show this help message"
            echo ""
            echo "This script installs and validates Python development tools:"
            echo "  - Python 3"
            echo "  - pip"
            echo "  - UV (Python package manager)"
            echo "  - Ruff (linter/formatter)"
            echo "  - VS Code"
            echo "  - VS Code extensions (Python, Ruff)"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo ""
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}💡 $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Installation Functions
###############################################################################

install_homebrew() {
    print_step "Checking Homebrew..."
    
    if command_exists brew; then
        print_success "Homebrew is already installed"
        if [ "$UPGRADE_MODE" = true ]; then
            print_step "Updating Homebrew..."
            brew update
            print_success "Homebrew updated"
        fi
    else
        print_warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed"
    fi
}

install_python() {
    print_step "Checking Python..."
    
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python is already installed: $PYTHON_VERSION"
        
        if [ "$UPGRADE_MODE" = true ]; then
            print_step "Upgrading Python..."
            brew upgrade python3 || print_warning "Python upgrade skipped (already latest or not installed via brew)"
        fi
    else
        print_warning "Python not found. Installing via Homebrew..."
        brew install python3
        print_success "Python installed"
    fi
}

install_pip() {
    print_step "Checking pip..."
    
    if python3 -m pip --version >/dev/null 2>&1; then
        PIP_VERSION=$(python3 -m pip --version | awk '{print $2}')
        print_success "pip is already installed: version $PIP_VERSION"
        
        if [ "$UPGRADE_MODE" = true ]; then
            print_step "Upgrading pip..."
            python3 -m pip install --upgrade pip
            print_success "pip upgraded"
        fi
    else
        print_warning "pip not found. Installing..."
        python3 -m ensurepip --upgrade
        python3 -m pip install --upgrade pip
        print_success "pip installed"
    fi
}

install_uv() {
    print_step "Checking UV..."
    
    if command_exists uv; then
        UV_VERSION=$(uv --version)
        print_success "UV is already installed: $UV_VERSION"
        
        if [ "$UPGRADE_MODE" = true ]; then
            print_step "Upgrading UV..."
            brew upgrade uv 2>/dev/null || python3 -m pip install --upgrade uv
            print_success "UV upgraded"
        fi
    else
        print_warning "UV not found. Installing via Homebrew..."
        if command_exists brew; then
            brew install uv
        else
            print_warning "Homebrew not available. Installing via pip..."
            python3 -m pip install uv
        fi
        print_success "UV installed"
    fi
}

install_vscode() {
    print_step "Checking VS Code..."
    
    if command_exists code; then
        VSCODE_VERSION=$(code --version | head -n 1)
        print_success "VS Code is already installed: version $VSCODE_VERSION"
        
        if [ "$UPGRADE_MODE" = true ]; then
            print_step "Upgrading VS Code..."
            brew upgrade --cask visual-studio-code || print_warning "VS Code upgrade skipped (not installed via brew)"
        fi
    else
        print_warning "VS Code 'code' command not found."
        
        # Check if VS Code app exists but command is missing
        if [ -d "/Applications/Visual Studio Code.app" ]; then
            print_info "VS Code app found but 'code' command not in PATH"
            print_info "Please open VS Code and run: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
        else
            print_warning "Installing VS Code via Homebrew..."
            brew install --cask visual-studio-code
            print_success "VS Code installed"
            print_info "You may need to run: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
        fi
    fi
}

install_vscode_extensions() {
    print_step "Checking VS Code Extensions..."
    
    if ! command_exists code; then
        print_warning "Cannot install extensions - 'code' command not available"
        return 1
    fi
    
    # Python extension
    if code --list-extensions | grep -q "ms-python.python"; then
        print_success "Python extension is already installed"
    else
        print_warning "Installing Python extension..."
        code --install-extension ms-python.python
        print_success "Python extension installed"
    fi
    
    # Ruff extension
    if code --list-extensions | grep -q "charliermarsh.ruff"; then
        print_success "Ruff extension is already installed"
    else
        print_warning "Installing Ruff extension..."
        code --install-extension charliermarsh.ruff
        print_success "Ruff extension installed"
    fi
}

install_ruff() {
    print_step "Checking Ruff..."
    
    # Check if in a project with pyproject.toml
    if [ -f "pyproject.toml" ]; then
        if uv run ruff --version >/dev/null 2>&1; then
            RUFF_VERSION=$(uv run ruff --version)
            print_success "Ruff is installed in project: $RUFF_VERSION"
            
            if [ "$UPGRADE_MODE" = true ]; then
                print_step "Upgrading Ruff in project..."
                uv add --dev ruff --upgrade
                print_success "Ruff upgraded in project"
            fi
        else
            print_warning "Ruff not found in project. Installing..."
            uv add --dev ruff
            print_success "Ruff installed in project"
        fi
    else
        # Try global installation
        if command_exists ruff; then
            RUFF_VERSION=$(ruff --version)
            print_success "Ruff is installed globally: $RUFF_VERSION"
            
            if [ "$UPGRADE_MODE" = true ]; then
                print_step "Upgrading Ruff globally..."
                brew upgrade ruff 2>/dev/null || python3 -m pip install --upgrade ruff
                print_success "Ruff upgraded globally"
            fi
        else
            print_warning "Ruff not found. Installing via Homebrew..."
            if command_exists brew; then
                brew install ruff
            else
                print_warning "Homebrew not available. Installing via pip..."
                python3 -m pip install ruff
            fi
            print_success "Ruff installed globally"
        fi
    fi
}

setup_project() {
    print_step "Checking project setup..."
    
    if [ -f "pyproject.toml" ]; then
        print_success "Project already initialized (pyproject.toml exists)"
        
        if [ -d ".venv" ]; then
            print_success "Virtual environment exists"
            
            if [ "$UPGRADE_MODE" = true ]; then
                print_step "Syncing dependencies..."
                uv sync
                print_success "Dependencies synced"
            fi
        else
            print_warning "Virtual environment not found. Creating..."
            uv sync
            print_success "Virtual environment created"
        fi
    else
        print_info "Not in a project directory (no pyproject.toml found)"
        print_info "Run 'uv init' to create a new project"
    fi
}

###############################################################################
# Validation Functions
###############################################################################

validate_python() {
    print_step "Validating Python..."
    if python3 --version >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version)
        print_success "$PYTHON_VERSION"
        return 0
    else
        print_error "Python not found"
        return 1
    fi
}

validate_pip() {
    print_step "Validating pip..."
    if python3 -m pip --version >/dev/null 2>&1; then
        PIP_VERSION=$(python3 -m pip --version | awk '{print $2}')
        print_success "pip version $PIP_VERSION"
        return 0
    else
        print_error "pip not found"
        return 1
    fi
}

validate_uv() {
    print_step "Validating UV..."
    if command_exists uv; then
        UV_VERSION=$(uv --version)
        print_success "$UV_VERSION"
        return 0
    else
        print_error "UV not found"
        return 1
    fi
}

validate_vscode() {
    print_step "Validating VS Code..."
    if command_exists code; then
        VSCODE_VERSION=$(code --version | head -n 1)
        print_success "VS Code version $VSCODE_VERSION"
        return 0
    else
        print_warning "VS Code 'code' command not found"
        if [ -d "/Applications/Visual Studio Code.app" ]; then
            print_info "VS Code app exists - add 'code' command via: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
        fi
        return 1
    fi
}

validate_extensions() {
    print_step "Validating VS Code Extensions..."
    if ! command_exists code; then
        print_warning "Cannot validate extensions - 'code' command not available"
        return 1
    fi
    
    local all_ok=true
    
    if code --list-extensions | grep -q "ms-python.python"; then
        print_success "Python extension installed"
    else
        print_warning "Python extension not installed"
        all_ok=false
    fi
    
    if code --list-extensions | grep -q "charliermarsh.ruff"; then
        print_success "Ruff extension installed"
    else
        print_warning "Ruff extension not installed"
        all_ok=false
    fi
    
    [ "$all_ok" = true ]
}

validate_ruff() {
    print_step "Validating Ruff..."
    
    # Check project-level first
    if [ -f "pyproject.toml" ] && uv run ruff --version >/dev/null 2>&1; then
        RUFF_VERSION=$(uv run ruff --version)
        print_success "Ruff (project): $RUFF_VERSION"
        return 0
    elif command_exists ruff; then
        RUFF_VERSION=$(ruff --version)
        print_success "Ruff (global): $RUFF_VERSION"
        return 0
    else
        print_warning "Ruff not found"
        print_info "Install with: uv add --dev ruff (in project) or: brew install ruff (globally)"
        return 1
    fi
}

validate_project() {
    print_step "Validating Project Setup..."
    
    local all_ok=true
    
    if [ -f "pyproject.toml" ]; then
        print_success "pyproject.toml exists"
    else
        print_info "pyproject.toml not found (run 'uv init' to create project)"
        all_ok=false
    fi
    
    if [ -f ".python-version" ]; then
        print_success ".python-version exists"
    else
        print_info ".python-version not found"
        all_ok=false
    fi
    
    if [ -d ".venv" ]; then
        print_success "Virtual environment exists"
    else
        print_info "Virtual environment not found (run 'uv sync' to create)"
        all_ok=false
    fi
    
    [ "$all_ok" = true ]
}

###############################################################################
# Main Script
###############################################################################

main() {
    print_header "🚀 Python Development Environment Setup"
    
    if [ "$UPGRADE_MODE" = true ]; then
        echo -e "${YELLOW}Running in UPGRADE mode - will update existing tools${NC}"
    else
        echo "Running in INSTALL mode - will only install missing tools"
        echo "Use --upgrade flag to upgrade existing tools"
    fi
    
    echo ""
    
    # Installation Phase
    print_header "📦 Installation Phase"
    
    install_homebrew
    install_python
    install_pip
    install_uv
    install_vscode
    install_vscode_extensions
    install_ruff
    setup_project
    
    # Validation Phase
    print_header "✅ Validation Phase"
    
    local critical_passed=0
    local critical_total=3
    local optional_passed=0
    local optional_total=4
    
    # Critical tools
    validate_python && ((critical_passed++)) || true
    validate_pip && ((critical_passed++)) || true
    validate_uv && ((critical_passed++)) || true
    
    # Optional tools
    validate_vscode && ((optional_passed++)) || true
    validate_extensions && ((optional_passed++)) || true
    validate_ruff && ((optional_passed++)) || true
    validate_project && ((optional_passed++)) || true
    
    # Summary
    print_header "📊 Summary"
    
    echo -e "Critical tools: ${critical_passed}/${critical_total} ✅"
    echo -e "Optional tools: ${optional_passed}/${optional_total} ✅"
    echo ""
    
    if [ $critical_passed -eq $critical_total ]; then
        print_success "All critical tools are installed! You're ready to start."
        if [ $optional_passed -lt $optional_total ]; then
            print_warning "Some optional tools need attention. Review messages above."
        fi
        echo ""
        print_info "Next steps:"
        echo "  1. Create a new project: uv init"
        echo "  2. Create virtual environment: uv sync"
        echo "  3. Open in VS Code: code ."
        echo "  4. Select Python interpreter: Cmd+Shift+P → 'Python: Select Interpreter'"
        echo ""
        return 0
    else
        print_error "Some critical tools are missing. Please review the output above."
        echo ""
        return 1
    fi
}

# Run main function
main
