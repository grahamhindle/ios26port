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

# Generate Project.swift using ModuleConstants dependencies
cat > "$MODULE_DIR/Project.swift" << EOF
import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "$MODULE_NAME",
    dependencies: Constants.commonDependencies
EOF

if [ "$AUTH_FLAG" = true ]; then
    cat >> "$MODULE_DIR/Project.swift" << EOF
        + Constants.authDependencies
EOF
fi

if [ -n "$CUSTOM_DEPS" ]; then
    cat >> "$MODULE_DIR/Project.swift" << EOF
        + [
EOF
    IFS=',' read -ra DEPS <<< "$CUSTOM_DEPS"
    for dep in "${DEPS[@]}"; do
        cat >> "$MODULE_DIR/Project.swift" << EOF
            .project(target: "$dep", path: "../$dep"),
EOF
    done
    cat >> "$MODULE_DIR/Project.swift" << EOF
        ]
EOF
fi

cat >> "$MODULE_DIR/Project.swift" << EOF
)

let project = Constants.createProject(config: config)
EOF

# Generate TCA feature files using templates
cd "$(dirname "$0")/.."

# Get current date and year
CURRENT_DATE=$(date +"%m/%d/%y")
CURRENT_YEAR=$(date +"%Y")
AUTHOR="Graham Hindle"
ORGANIZATION="grahamhindle"

# Generate TCA Feature file
cat > "$MODULE_DIR/Sources/${MODULE_NAME}Feature.swift" << EOF
//
//  ${MODULE_NAME}Feature.swift
//  ${MODULE_NAME}
//
//  Created by ${AUTHOR} on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} ${ORGANIZATION}. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ${MODULE_NAME}Feature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
EOF

# Generate TCA View file
cat > "$MODULE_DIR/Sources/${MODULE_NAME}View.swift" << EOF
//
//  ${MODULE_NAME}View.swift
//  ${MODULE_NAME}
//
//  Created by ${AUTHOR} on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} ${ORGANIZATION}. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct ${MODULE_NAME}View: View {
    @Bindable var store: StoreOf<${MODULE_NAME}Feature>
    
    public init(store: StoreOf<${MODULE_NAME}Feature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text("${MODULE_NAME}")
                .font(.title)
            
            Text("Feature View")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ${MODULE_NAME}View(
        store: Store(initialState: ${MODULE_NAME}Feature.State()) {
            ${MODULE_NAME}Feature()
        }
    )
}
EOF

# Generate Demo App
cat > "$MODULE_DIR/Demo/${MODULE_NAME}DemoApp.swift" << EOF
//
//  ${MODULE_NAME}DemoApp.swift
//  ${MODULE_NAME}Demo
//
//  Created by ${AUTHOR} on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} ${ORGANIZATION}. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import ${MODULE_NAME}

@main
struct ${MODULE_NAME}DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ${MODULE_NAME}View(
                store: Store(initialState: ${MODULE_NAME}Feature.State()) {
                    ${MODULE_NAME}Feature()
                }
            )
        }
    }
}
EOF

# Generate Test file
cat > "$MODULE_DIR/Tests/${MODULE_NAME}Tests.swift" << EOF
//
//  ${MODULE_NAME}Tests.swift
//  ${MODULE_NAME}Tests
//
//  Created by ${AUTHOR} on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} ${ORGANIZATION}. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import ${MODULE_NAME}

@MainActor
final class ${MODULE_NAME}Tests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(initialState: ${MODULE_NAME}Feature.State()) {
            ${MODULE_NAME}Feature()
        }
        
        await store.send(.onAppear) {
            // Verify state changes if any
        }
        
        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
}
EOF

echo "✅ Created modern module: $MODULE_NAME"
echo "📁 Location: $MODULE_DIR"
echo "🔧 Project.swift uses ModuleConfig approach"
echo "🎯 Generated complete TCA feature structure" 