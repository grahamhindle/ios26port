#!/usr/bin/env swift

import Foundation

struct ModuleDependency {
    let name: String
    let dependencies: [String]
    let externalDependencies: [String]
}

func analyzeProjectFile(_ path: String) -> ModuleDependency? {
    guard let content = try? String(contentsOfFile: path) else { return nil }
    
    // Extract module name
    let namePattern = #"name: "([^"]+)""#
    let nameRegex = try! NSRegularExpression(pattern: namePattern)
    guard let nameMatch = nameRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) else { return nil }
    let moduleName = String(content[Range(nameMatch.range(at: 1), in: content)!])
    
    // Extract project dependencies  
    let projectDepPattern = #"\.project\(target: "([^"]+)""#
    let projectRegex = try! NSRegularExpression(pattern: projectDepPattern)
    let projectDeps = projectRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        .compactMap { match in
            String(content[Range(match.range(at: 1), in: content)!])
        }
    
    // Extract external dependencies
    let externalDepPattern = #"\.external\(name: "([^"]+)""#
    let externalRegex = try! NSRegularExpression(pattern: externalDepPattern)
    let externalDeps = externalRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        .compactMap { match in
            String(content[Range(match.range(at: 1), in: content)!])
        }
    
    return ModuleDependency(
        name: moduleName,
        dependencies: projectDeps,
        externalDependencies: externalDeps
    )
}

func findCircularDependencies(_ modules: [ModuleDependency]) -> [[String]] {
    var visited = Set<String>()
    var recursionStack = Set<String>()
    var cycles: [[String]] = []
    
    func dfs(_ module: String, path: [String]) -> Bool {
        if recursionStack.contains(module) {
            if let cycleStart = path.firstIndex(of: module) {
                cycles.append(Array(path[cycleStart...]) + [module])
            }
            return true
        }
        
        if visited.contains(module) { return false }
        
        visited.insert(module)
        recursionStack.insert(module)
        
        let currentModule = modules.first { $0.name == module }
        for dependency in currentModule?.dependencies ?? [] {
            if dfs(dependency, path: path + [module]) {
                return true
            }
        }
        
        recursionStack.remove(module)
        return false
    }
    
    for module in modules {
        if !visited.contains(module.name) {
            _ = dfs(module.name, path: [])
        }
    }
    
    return cycles
}

// Analyze all modules
let modulesPaths = try FileManager.default.contentsOfDirectory(atPath: "Modules")
    .compactMap { dir in
        let projectPath = "Modules/\(dir)/Project.swift"
        return FileManager.default.fileExists(atPath: projectPath) ? projectPath : nil
    }

let modules = modulesPaths.compactMap(analyzeProjectFile)

print("📊 Dependency Analysis Report")
print("============================")

for module in modules {
    print("\n📦 \(module.name)")
    if !module.dependencies.isEmpty {
        print("  Internal deps: \(module.dependencies.joined(separator: ", "))")
    }
    if !module.externalDependencies.isEmpty {
        print("  External deps: \(module.externalDependencies.joined(separator: ", "))")
    }
}

let cycles = findCircularDependencies(modules)
if cycles.isEmpty {
    print("\n✅ No circular dependencies found!")
} else {
    print("\n❌ Circular dependencies detected:")
    for cycle in cycles {
        print("  \(cycle.joined(separator: " → "))")
    }
}