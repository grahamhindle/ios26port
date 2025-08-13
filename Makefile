.PHONY: help generate build test run clean new-module tuist-status tuist-clean tuist-fresh tuist-graph tuist-lint tuist-info tuist-deps tuist-cache tuist-cache-warm

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

new-module: ## Create new module (usage: make new-module name=FeatureName)
ifndef name
	$(error Please provide module name: make new-module name=FeatureName)
endif
	@./Scripts/new-module.sh $(name)

generate: ## Generate Xcode project
	@tuist install
	@tuist generate

build: ## Build the project
	@tuist build

build-module: ## Build specific module (usage: make build-module module=AuthFeature)
ifdef module
	@echo "🔨 Building module: $(module)"
	@xcodebuild -workspace ios26port.xcworkspace -scheme $(module) build
else
	@echo "Please provide a module name: make build-module module=AuthFeature"
endif

test: ## Run tests
	@tuist test

run: ## Run module (usage: make run module=FeatureName)
ifdef module
	@echo "🚀 Booting simulator..."
	@xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true
	@echo "🚀 Building and running $(module)..."
	@tuist run $(module)
else
	@echo "Please provide a module name: make run module=FeatureName"
endif

clean: ## Clean derived data
	@tuist clean

setup: ## Initial project setup
	@tuist install
	@tuist generate
	@echo "✅ Project setup complete!"

focus: ## Focus on specific module (usage: make focus module=FeatureName)
ifdef module
	@echo "Focusing on $(module)..."
	@tuist focus $(module)
else
	@echo "Please provide a module name: make focus module=FeatureName"
endif

# Tuist Helper Commands
tuist-status: ## Show Tuist project status and modules
	@./Scripts/tuist-helper.sh status

tuist-clean: ## Clean all Tuist artifacts and generated files
	@./Scripts/tuist-helper.sh clean-all

tuist-fresh: ## Clean and regenerate project from scratch
	@./Scripts/tuist-helper.sh fresh-generate

tuist-graph: ## Generate dependency graph visualization
	@./Scripts/tuist-helper.sh graph

tuist-lint: ## Lint Tuist project configuration
	@./Scripts/tuist-helper.sh lint

tuist-info: ## Show module info (usage: make tuist-info module=FeatureName)
ifdef module
	@./Scripts/tuist-helper.sh module-info $(module)
else
	@echo "Please provide a module name: make tuist-info module=FeatureName"
endif

tuist-deps: ## Show project dependencies
	@./Scripts/tuist-helper.sh dependencies

analyze-deps: ## Analyze module dependencies and detect circular dependencies
	@echo "🔍 Analyzing module dependencies..."
	@tuist run DependencyAnalyzer

tuist-cache: ## Cache external dependencies for faster builds
	@echo "🚀 Caching external dependencies..."
	@tuist cache --external-only

tuist-cache-warm: ## Warm cache for all targets
	@echo "🔥 Warming cache for all targets..."
	@tuist cache

# Code Quality Commands
format: ## Format Swift code using SwiftFormat
	@echo "🔧 Formatting Swift code..."
	@swiftformat .

format-check: ## Check Swift code formatting without modifying files
	@echo "🔍 Checking Swift code formatting..."
	@swiftformat . --lint

lint: ## Lint Swift code using SwiftLint
	@echo "🔍 Linting Swift code..."
	@swiftlint

lint-fix: ## Auto-fix SwiftLint violations where possible
	@echo "🔧 Auto-fixing SwiftLint violations..."
	@swiftlint --fix