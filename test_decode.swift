import Foundation

// Copy the Step1Core3 struct here for testing
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
}

struct Core3: Codable {
    let step1: Step1Core3
}

struct TestData: Codable {
    let core3: Core3
}

do {
    let jsonString = """
    {
      "core3": {
        "step1": {
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
      }
    }
    """

    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let testData = try decoder.decode(TestData.self, from: jsonData)

    print("sentence_target: \(testData.core3.step1.sentence_target)")
    print("word_order_target: \(testData.core3.step1.word_order_target)")
    print("native_order_chunks: \(testData.core3.step1.native_order_chunks)")
    print("native_sentence: '\(testData.core3.step1.native_sentence)'")

} catch {
    print("Error: \(error)")
}
