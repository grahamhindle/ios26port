#!/bin/bash

MODULE_NAME=$1
MODULE_DIR="Modules/$MODULE_NAME"

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: ./setup-module.sh <ModuleName>"
    exit 1
fi

# Create module directory
mkdir -p "$MODULE_DIR/Sources"
mkdir -p "$MODULE_DIR/Tests" 
mkdir -p "$MODULE_DIR/Demo"
mkdir -p "$MODULE_DIR/Demo/Resources"



# Create basic Project.swift
cat > "$MODULE_DIR/Project.swift" << EOF
import ProjectDescription

let project = Project(
    name: "$MODULE_NAME",
    targets: [
        ModuleConstants.frameworkTarget(
            name: "$MODULE_NAME",
            dependencies: [
                // Add your dependencies here
                // .external(name: "SomeDependency"),
                // .project(target: "SharedModels", path: "../SharedModels")
            ]
        ),
        ModuleConstants.testTarget(
            name: "${MODULE_NAME}Tests",
            testedTargetName: "$MODULE_NAME"
        ),
        ModuleConstants.appTarget(
            name: "${MODULE_NAME}Demo",
            dependencies: [
                .target(name: "$MODULE_NAME")
            ]
        )
    ]
)
EOF

# Generate template files from Stencil templates
AUTHOR="Graham Hindle"
ORGANIZATION="grahamhindle"
CURRENT_DATE=$(date +"%m/%d/%y")
CURRENT_YEAR=$(date +"%Y")

# Generate Demo main file
sed -e "s|{{ moduleName }}|$MODULE_NAME|g" \
    -e "s|{{ author }}|$AUTHOR|g" \
    -e "s|{{ organization }}|$ORGANIZATION|g" \
    -e "s|{{ date }}|$CURRENT_DATE|g" \
    -e "s|{{ year }}|$CURRENT_YEAR|g" \
    -e "s|{{ fileName }}|${MODULE_NAME}DemoApp|g" \
    Tuist/ProjectDescriptionHelpers/Templates/DemoMain.stencil > "$MODULE_DIR/Demo/${MODULE_NAME}DemoApp.swift"

# Generate test file
sed -e "s|{{ moduleName }}|$MODULE_NAME|g" \
    -e "s|{{ author }}|$AUTHOR|g" \
    -e "s|{{ organization }}|$ORGANIZATION|g" \
    -e "s|{{ date }}|$CURRENT_DATE|g" \
    -e "s|{{ year }}|$CURRENT_YEAR|g" \
    -e "s|{{ fileName }}|${MODULE_NAME}Tests|g" \
    Tuist/ProjectDescriptionHelpers/Templates/TestTemplate.stencil > "$MODULE_DIR/Tests/${MODULE_NAME}Tests.swift"

# Generate view file
sed -e "s|{{ moduleName }}|$MODULE_NAME|g" \
    -e "s|{{ author }}|$AUTHOR|g" \
    -e "s|{{ organization }}|$ORGANIZATION|g" \
    -e "s|{{ date }}|$CURRENT_DATE|g" \
    -e "s|{{ year }}|$CURRENT_YEAR|g" \
    -e "s|{{ fileName }}|${MODULE_NAME}View|g" \
    -e "s|{{ className }}|${MODULE_NAME}View|g" \
    Tuist/ProjectDescriptionHelpers/Templates/ViewTemplate.stencil > "$MODULE_DIR/Sources/${MODULE_NAME}View.swift"

# Generate class file
sed -e "s|{{ moduleName }}|$MODULE_NAME|g" \
    -e "s|{{ author }}|$AUTHOR|g" \
    -e "s|{{ organization }}|$ORGANIZATION|g" \
    -e "s|{{ date }}|$CURRENT_DATE|g" \
    -e "s|{{ year }}|$CURRENT_YEAR|g" \
    -e "s|{{ fileName }}|${MODULE_NAME}Manager|g" \
    -e "s|{{ className }}|${MODULE_NAME}Manager|g" \
    Tuist/ProjectDescriptionHelpers/Templates/ClassTemplate.stencil > "$MODULE_DIR/Sources/${MODULE_NAME}Manager.swift"

echo "📝 Generated template files:"
echo "   - Demo/${MODULE_NAME}DemoApp.swift"
echo "   - Tests/${MODULE_NAME}Tests.swift" 
echo "   - Sources/${MODULE_NAME}View.swift"
echo "   - Sources/${MODULE_NAME}Manager.swift"

echo "✅ Created module: $MODULE_NAME"
echo "📁 Location: $MODULE_DIR"
echo "🔗 Demo resources will be shared from SharedResources/Demo/"
echo "   - Auth0.plist (centralized Auth0 configuration)"
echo "   - Demo.entitlements (centralized entitlements)"

echo ""
echo "Next steps:"
echo "1. Add your source files to $MODULE_DIR/Sources/"
echo "2. Update dependencies in $MODULE_DIR/Project.swift"
echo "3. Add module to root Workspace.swift"
echo "4. Module-specific demo resources go in $MODULE_DIR/Demo/Resources/"