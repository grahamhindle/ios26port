#!/bin/bash

# Validate each module can build independently
MODULES_DIR="Modules"
FAILED_MODULES=()

echo "🔍 Validating module independence..."

for module_dir in "$MODULES_DIR"/*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Building $module_name..."
        
        cd "$module_dir"
        
        # Try to generate and build the module
        if tuist generate && xcodebuild -scheme "$module_name" -destination "platform=iOS Simulator,name=iPhone 15" build; then
            echo "✅ $module_name builds successfully"
        else
            echo "❌ $module_name failed to build"
            FAILED_MODULES+=("$module_name")
        fi
        
        cd "../.."
    fi
done

if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
    echo "🎉 All modules build successfully!"
else
    echo "💥 Failed modules: ${FAILED_MODULES[*]}"
    exit 1
fi