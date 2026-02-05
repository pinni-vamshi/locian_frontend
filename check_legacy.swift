import NaturalLanguage

let languages = ["ar", "ru", "ta", "zh", "zh-Hans"]

print("--- Checking Legacy (Static) Embedding Support ---")

for code in languages {
    let lang = NLLanguage(rawValue: code)
    print("\nChecking: '\(code)'")
    
    if NLEmbedding.sentenceEmbedding(for: lang) != nil {
        print("   ✅ Sentence Embedding: Supported")
    } else {
        print("   ❌ Sentence Embedding: Not Supported")
    }
    
    if NLEmbedding.wordEmbedding(for: lang) != nil {
        print("   ✅ Word Embedding: Supported")
    } else {
        print("   ❌ Word Embedding: Not Supported")
    }
}
