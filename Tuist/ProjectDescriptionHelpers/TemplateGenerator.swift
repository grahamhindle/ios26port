import Foundation

public enum TemplateGenerator {
    
    public static func generateFiles(for moduleName: String, in moduleDir: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let currentDate = dateFormatter.string(from: Date())
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        
        let context: [String: String] = [
            "moduleName": moduleName,
            "author": Constants.author,
            "organization": Constants.organization,
            "date": currentDate,
            "year": currentYear
        ]
        
        // Generate Project.swift
        generateProjectFile(moduleName: moduleName, moduleDir: moduleDir, context: context)
        
        // Generate Demo main file
        generateDemoMain(moduleName: moduleName, moduleDir: moduleDir, context: context)
        
        // Generate test file
        generateTestFile(moduleName: moduleName, moduleDir: moduleDir, context: context)
        
        // Generate basic view
        generateViewFile(moduleName: moduleName, moduleDir: moduleDir, context: context)
        
        // Generate basic class
        generateClassFile(moduleName: moduleName, moduleDir: moduleDir, context: context)
    }
    
    private static func generateProjectFile(moduleName: String, moduleDir: String, context: [String: String]) {
        let template = readTemplate("ProjectTemplate")
        var content = template
        
        for (key, value) in context {
            content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
        }
        
        // Remove conditional blocks that aren't needed
        content = content.replacingOccurrences(of: "\\s*{{#if hasAuth}}[\\s\\S]*?{{/if}}\\s*", with: "", options: .regularExpression)
        content = content.replacingOccurrences(of: "\\s*{{#each customDependencies}}[\\s\\S]*?{{/each}}\\s*", with: "", options: .regularExpression)
        content = content.replacingOccurrences(of: "\\s*{{#if customSettings}}[\\s\\S]*?{{/if}}\\s*", with: "", options: .regularExpression)
        content = content.replacingOccurrences(of: "\\s*{{#if customTestDependencies}}[\\s\\S]*?{{/if}}\\s*", with: "", options: .regularExpression)
        content = content.replacingOccurrences(of: "\\s*{{#if customDemoDependencies}}[\\s\\S]*?{{/if}}\\s*", with: "", options: .regularExpression)
        
        // Clean up trailing commas
        content = content.replacingOccurrences(of: ",\\s*]", with: "]", options: .regularExpression)
        content = content.replacingOccurrences(of: ",\\s*\\)", with: ")", options: .regularExpression)
        
        writeFile(content: content, to: "\(moduleDir)/Project.swift")
    }
    
    private static func generateDemoMain(moduleName: String, moduleDir: String, context: [String: String]) {
        let template = readTemplate("DemoMain")
        var content = template
        var contextWithFileName = context
        contextWithFileName["fileName"] = "\(moduleName)DemoApp"
        
        for (key, value) in contextWithFileName {
            content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
        }
        
        writeFile(content: content, to: "\(moduleDir)/Demo/\(moduleName)DemoApp.swift")
    }
    
    private static func generateTestFile(moduleName: String, moduleDir: String, context: [String: String]) {
        let template = readTemplate("TestTemplate")
        var content = template
        var contextWithFileName = context
        contextWithFileName["fileName"] = "\(moduleName)Tests"
        
        for (key, value) in contextWithFileName {
            content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
        }
        
        writeFile(content: content, to: "\(moduleDir)/Tests/\(moduleName)Tests.swift")
    }
    
    private static func generateViewFile(moduleName: String, moduleDir: String, context: [String: String]) {
        let template = readTemplate("ViewTemplate")
        var content = template
        var contextWithFileName = context
        contextWithFileName["fileName"] = "\(moduleName)View"
        contextWithFileName["className"] = "\(moduleName)View"
        
        for (key, value) in contextWithFileName {
            content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
        }
        
        writeFile(content: content, to: "\(moduleDir)/Sources/\(moduleName)View.swift")
    }
    
    private static func generateClassFile(moduleName: String, moduleDir: String, context: [String: String]) {
        let template = readTemplate("ClassTemplate")
        var content = template
        var contextWithFileName = context
        contextWithFileName["fileName"] = "\(moduleName)Manager"
        contextWithFileName["className"] = "\(moduleName)Manager"
        
        for (key, value) in contextWithFileName {
            content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
        }
        
        writeFile(content: content, to: "\(moduleDir)/Sources/\(moduleName)Manager.swift")
    }
    
    private static func readTemplate(_ name: String) -> String {
        let templatePath = "Tuist/ProjectDescriptionHelpers/Templates/\(name).stencil"
        do {
            return try String(contentsOfFile: templatePath, encoding: .utf8)
        } catch {
            print("⚠️ Could not read template \(name): \(error)")
            return ""
        }
    }
    
    private static func writeFile(content: String, to path: String) {
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            print("✅ Created: \(path)")
        } catch {
            print("❌ Failed to create \(path): \(error)")
        }
    }
}