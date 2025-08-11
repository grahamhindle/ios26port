import SwiftUI
import DatabaseModule

@main
struct DatabaseModuleDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DatabaseDemoView()
        }
    }
}

struct DatabaseDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("DatabaseModule Demo")
                .font(.largeTitle)
                .bold()

            Text("Database functionality is working!")
                .foregroundColor(.secondary)

            Button("Test Database") {
                do {
                    let db = try appDatabase()
                    print("Database created successfully: \(db)")
                } catch {
                    print("Database error: \(error)")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    DatabaseDemoView()
}
