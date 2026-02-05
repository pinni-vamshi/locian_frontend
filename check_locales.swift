import NaturalLanguage

if #available(macOS 14.0, *) {
    let localesToCheck = ["ar", "ru", "ta", "zh", "zh-Hans", "zh-Hant"]
    
    print("--- Checking Locale Support for Contextual Embeddings ---")
    
    for code in localesToCheck {
        let lang = NLLanguage(rawValue: code)
        print("\nChecking: '\(code)'")
        
        let model = NLContextualEmbedding(language: lang)
        
        if let model = model {
            print("✅ Instantiated (Not Nil)")
            print("   Assets Available: \(model.hasAvailableAssets)")
            
            // Check if we can request assets (mock call)
            // model.requestAssets { ... }
        } else {
            print("❌ Failed to Instantiate (Returned Nil)")
        }
    }
} else {
    print("Skipping check (older OS)")
}
