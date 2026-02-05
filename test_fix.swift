import Foundation

struct Step1Core3: Codable {
    let sentence_target: String
    let word_order_target: [String: String]
    let native_order_chunks: [String]

    enum CodingKeys: String, CodingKey {
        case sentence_target
        case word_order_target
        case native_order_chunks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sentence_target = try container.decode(String.self, forKey: .sentence_target)
        word_order_target = try container.decode([String: String].self, forKey: .word_order_target)
        native_order_chunks = try container.decodeIfPresent([String].self, forKey: .native_order_chunks) ?? []
    }

    var native_sentence: String {
        native_order_chunks.joined(separator: " ")
    }

    // Fixed native_words implementation
    var native_words: [String] {
        // Find keys in order of their appearance in sentence_target
        let sortedKeys = word_order_target.keys.sorted { key1, key2 in
            let range1 = sentence_target.range(of: key1)
            let range2 = sentence_target.range(of: key2)
            return range1?.lowerBound ?? sentence_target.endIndex < range2?.lowerBound ?? sentence_target.endIndex
        }
        return sortedKeys
    }
}

do {
    let jsonString = """
    {
      "sentence_target": "காலை உணவுக்கு பால் போதுமா?",
      "word_order_target": {
        "காலை உணவுக்கு": "kaalai unavukku",
        "பால்": "paal",
        "போதுமா": "pothuma"
      },
      "native_order_chunks": [
        "for breakfast",
        "milk",
        "enough?"
      ]
    }
    """

    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let step = try decoder.decode(Step1Core3.self, from: jsonData)

    print("sentence_target: \(step.sentence_target)")
    print("native_words: \(step.native_words)")
    print("native_sentence: '\(step.native_sentence)'")

} catch {
    print("Error: \(error)")
}
