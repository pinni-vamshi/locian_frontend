import NaturalLanguage
import Foundation

if #available(macOS 14.0, *) {
    let code = "ar"
    let lang = NLLanguage(rawValue: code)
    print("--- Verifying Download for '\(code)' ---")
    
    if let model = NLContextualEmbedding(language: lang) {
        print("✅ Model instantiated.")
        print("   Current Assets Available: \(model.hasAvailableAssets)")
        
        if model.hasAvailableAssets {
            print("   (already has assets)")
            exit(0)
        }
        
        print("   ⬇️ Requesting assets (Timeout: 30s)...")
        let semaphore = DispatchSemaphore(value: 0)
        
        model.requestAssets { result, error in
            print("   📩 Callback received!")
            if result == .available {
                print("   ✅ SUCCESS: Assets available.")
            } else {
                print("   ❌ FAILURE: \(error?.localizedDescription ?? "Unknown error")")
            }
            semaphore.signal()
        }
        
        let waitResult = semaphore.wait(timeout: .now() + 30)
        if waitResult == .timedOut {
            print("   ❌ TIMEOUT: Callback never fired within 30s.")
        }
        
    } else {
        print("❌ Failed to instantiate model for '\(code)'.")
    }
} else {
    print("Skipping check (older OS)")
}
