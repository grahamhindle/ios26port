#!/bin/bash

# Tuist Helper Script for Claude Code Integration
# Provides common Tuist operations with better output formatting

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Change to project root
cd "$PROJECT_ROOT"

case "$1" in
    "status")
        log_info "Checking Tuist project status..."
        echo "Project Root: $PROJECT_ROOT"
        echo "Tuist Version: $(tuist version)"
        echo ""
        
        if [ -f "Project.swift" ]; then
            log_success "Project.swift found"
        else
            log_error "Project.swift not found"
        fi
        
        if [ -f "Workspace.swift" ]; then
            log_success "Workspace.swift found"
        else
            log_warning "Workspace.swift not found"
        fi
        
        if [ -d ".build" ]; then
            log_info "Build artifacts present"
        else
            log_info "No build artifacts found"
        fi
        
        echo ""
        log_info "Available modules:"
        find Modules -name "Project.swift" -exec dirname {} \; | sed 's|Modules/||' | sort
        ;;
        
    "clean-all")
        log_info "Cleaning all Tuist artifacts..."
        tuist clean
        rm -rf .build
        rm -rf Derived
        find . -name "*.xcworkspace" -delete
        find . -name "*.xcodeproj" -delete
        log_success "Clean completed"
        ;;
        
    "fresh-generate")
        log_info "Fresh project generation..."
        $0 clean-all
        tuist install
        tuist generate
        log_success "Fresh generation completed"
        ;;
        
    "module-info")
        if [ -z "$2" ]; then
            log_error "Usage: $0 module-info <module-name>"
            exit 1
        fi
        
        MODULE_PATH="Modules/$2"
        if [ -d "$MODULE_PATH" ]; then
            log_info "Module: $2"
            echo "Path: $MODULE_PATH"
            echo ""
            
            if [ -f "$MODULE_PATH/Project.swift" ]; then
                log_info "Project.swift content:"
                cat "$MODULE_PATH/Project.swift"
            fi
            
            echo ""
            log_info "Module structure:"
            tree "$MODULE_PATH" 2>/dev/null || find "$MODULE_PATH" -type f | sort
        else
            log_error "Module '$2' not found in Modules directory"
        fi
        ;;
        
    "dependencies")
        log_info "Project dependencies:"
        if [ -f "Tuist/Package.swift" ]; then
            echo "External dependencies (Tuist/Package.swift):"
            grep -A 20 "dependencies:" "Tuist/Package.swift" | head -20
        fi
        
        echo ""
        log_info "Module dependencies:"
        find Modules -name "Project.swift" -exec grep -l "dependencies:" {} \; | while read -r file; do
            module=$(dirname "$file" | sed 's|Modules/||')
            echo "Module: $module"
            grep -A 10 "dependencies:" "$file" | head -10 | sed 's/^/  /'
            echo ""
        done
        ;;
        
    "graph")
        log_info "Generating dependency graph..."
        tuist graph --format png --output-path ./tuist-graph.png
        if [ -f "./tuist-graph.png" ]; then
            log_success "Dependency graph saved to tuist-graph.png"
        else
            log_error "Failed to generate dependency graph"
        fi
        ;;
        
    "focus")
        if [ -z "$2" ]; then
            log_error "Usage: $0 focus <module-name>"
            exit 1
        fi
        
        log_info "Focusing on module: $2"
        tuist focus "$2"
        log_success "Focus completed for $2"
        ;;
        
    "lint")
        log_info "Running Tuist project linting..."
        tuist lint project
        ;;
        
    "help")
        echo "Tuist Helper Script"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  status           - Show project status and available modules"
        echo "  clean-all        - Clean all build artifacts and generated files"
        echo "  fresh-generate   - Clean and regenerate project from scratch"
        echo "  module-info <name> - Show detailed information about a module"
        echo "  dependencies     - Show project and module dependencies"
        echo "  graph           - Generate dependency graph visualization"
        echo "  focus <module>  - Focus on specific module"
        echo "  lint            - Lint Tuist project configuration"
        echo "  help            - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 module-info AuthFeature"
        echo "  $0 focus HomeFeature"
        echo "  $0 fresh-generate"
        ;;
        
    *)
        log_error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac