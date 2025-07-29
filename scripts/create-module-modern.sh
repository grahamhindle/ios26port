#!/bin/bash

# Modern Module Creation Script using ModuleConfig
# Usage: ./create-module-modern.sh ModuleName [--auth] [--custom-deps]

MODULE_NAME=$1
AUTH_FLAG=false
CUSTOM_DEPS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auth)
            AUTH_FLAG=true
            shift
            ;;
        --custom-deps)
            CUSTOM_DEPS="$2"
            shift 2
            ;;
        *)
            MODULE_NAME=$1
            shift
            ;;
    esac
done

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 ModuleName [--auth] [--custom-deps 'dep1,dep2']"
    exit 1
fi

MODULE_DIR="Modules/$MODULE_NAME"

# Create directory structure
mkdir -p "$MODULE_DIR"/{Sources,Demo,Tests,Demo/Resources}

# Generate Project.swift using the new approach
cat > "$MODULE_DIR/Project.swift" << EOF
import ProjectDescription

let config = ModuleConfig(
    name: "$MODULE_NAME",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
EOF

if [ "$AUTH_FLAG" = true ]; then
    cat >> "$MODULE_DIR/Project.swift" << EOF
        .external(name: "Auth0"),
        .external(name: "SharingGRDB"),
EOF
fi

if [ -n "$CUSTOM_DEPS" ]; then
    IFS=',' read -ra DEPS <<< "$CUSTOM_DEPS"
    for dep in "${DEPS[@]}"; do
        cat >> "$MODULE_DIR/Project.swift" << EOF
        .project(target: "$dep", path: "../$dep"),
EOF
    done
fi

cat >> "$MODULE_DIR/Project.swift" << EOF
    ]
)

let project = Constants.createProject(config: config)
EOF

# Generate other files using existing template generator
cd "$(dirname "$0")/.."
swift run TemplateGenerator generateFiles --module "$MODULE_NAME" --directory "$MODULE_DIR"

echo "✅ Created modern module: $MODULE_NAME"
echo "📁 Location: $MODULE_DIR"
echo "🔧 Project.swift uses ModuleConfig approach" 