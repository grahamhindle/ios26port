#!/bin/bash

set -e

if [ -z "$1" ]; then
   echo "Usage: ./Scripts/new-module.sh ModuleName"
   exit 1
fi

MODULE_NAME=$1

echo "🚀 Creating independent TCA module: ${MODULE_NAME}Feature (Swift 6 + iOS 18.4)"

# Generate module using Tuist template
tuist scaffold tca-module --name "$MODULE_NAME"

# Add to workspace automatically
echo "📝 Adding module to Workspace.swift..."

# Create backup
cp Workspace.swift Workspace.swift.backup

# Add module to workspace projects array
sed -i '' "/\"Modules\/ProfileFeature\",/a\\
       \"Modules/${MODULE_NAME}Feature\",
" Workspace.swift

# Add fastlane lanes for the new module
if [ -f "fastlane/Fastfile" ]; then
    echo "🔧 Adding fastlane lanes for ${MODULE_NAME}Feature..."
    ./Scripts/add-fastlane-lanes.sh "${MODULE_NAME}Feature"
else
    echo "⚠️  fastlane/Fastfile not found, skipping fastlane lane creation"
fi

echo "✅ Module ${MODULE_NAME}Feature created successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Run 'tuist generate' to update Xcode workspace"
echo "   2. Start developing your feature!"
echo "   3. Use the ${MODULE_NAME}FeatureDemo scheme to test your module independently"
echo ""
echo "🎯 Demo App: Run '${MODULE_NAME}FeatureDemo' scheme for standalone testing"
echo "💡 Don't forget to run 'tuist generate' to include the new module in your workspace!"
