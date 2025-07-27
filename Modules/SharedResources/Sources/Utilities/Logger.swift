import Foundation

func logTCAChange(_ message: String) {
    // Print with a unique prefix for easy filtering
    print("🟦 TCA STATE CHANGE: \(message)")

    // Optionally, also write to a file:
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("tca_state_changes.log")
    if let data = (message + "\n").data(using: .utf8) {
        if FileManager.default.fileExists(atPath: url.path) {
            if let fileHandle = try? FileHandle(forWritingTo: url) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: url)
        }
    }
}
