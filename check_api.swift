import NaturalLanguage
import Foundation

if #available(macOS 14.0, *) {
    let tamil = NLLanguage("ta")
    print("--- Checking API ---")
    
    // Abstract check since we can't easily introspect methods at runtime without ObjC runtime,
    // but we can try to compile a snippet that uses the properties we expect.
    
    // We will just try to print if we can instantiate it, 
    // but the real test is compilation.
    
    // Mock usage to fail/succeed compilation of this script
    func test(result: NLContextualEmbeddingResult, text: String) {
        // Option A: vector(for:)
        let range = text.startIndex..<text.endIndex
        let v = result.vector(for: text.startIndex..<text.endIndex) // Check if this compiles
        print("Vector exists: \(v != nil)")
    }
} else {
    print("Skipping check (older OS)")
}
