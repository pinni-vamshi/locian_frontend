import Foundation
import NaturalLanguage

/// Service for on-device morphological analysis using Apple's NaturalLanguage framework.
struct TokenTaggerService {
    
    /// Tags a sentence with lexical classes (Parts of Speech).
    /// Returns a dictionary: ["word": "Noun", "word2": "Verb"]
    static func tagContent(text: String, languageCode: String? = nil) -> [String: String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        if let lang = languageCode {
            tagger.setLanguage(NLLanguage(rawValue: lang), range: text.startIndex..<text.endIndex)
        }
        
        var tags: [String: String] = [:]
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
            if let tag = tag {
                let word = String(text[range]).lowercased()
                tags[word] = tag.rawValue
            }
            return true
        }
        
        return tags
    }
    
    /// Returns true if the word is classified as a Noun.
    static func isNoun(_ word: String, in tags: [String: String]) -> Bool {
        guard let tag = tags[word.lowercased()] else { return false }
        return tag == NLTag.noun.rawValue
    }
    
    /// Returns true if the word is classified as a Verb.
    static func isVerb(_ word: String, in tags: [String: String]) -> Bool {
        guard let tag = tags[word.lowercased()] else { return false }
        return tag == NLTag.verb.rawValue
    }
    
    /// Returns true if the word is classified as an Adjective.
    static func isAdjective(_ word: String, in tags: [String: String]) -> Bool {
        guard let tag = tags[word.lowercased()] else { return false }
        return tag == NLTag.adjective.rawValue
    }
    
    /// Returns true if the word is classified as an Adverb.
    static func isAdverb(_ word: String, in tags: [String: String]) -> Bool {
        guard let tag = tags[word.lowercased()] else { return false }
        return tag == NLTag.adverb.rawValue
    }
    
    /// Returns true if the word is a "Content Word" (Noun, Verb, Adjective, Adverb).
    /// These are typically the "Variables" in our lesson logic.
    static func isContentWord(_ word: String, in tags: [String: String]) -> Bool {
        return isNoun(word, in: tags) || isVerb(word, in: tags) || isAdjective(word, in: tags) || isAdverb(word, in: tags)
    }
}
