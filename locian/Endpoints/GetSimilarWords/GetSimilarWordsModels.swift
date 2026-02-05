//
//  GetSimilarWordsModels.swift
//  locian
//

import Foundation

struct GetSimilarWordsRequest: Codable {
    let word: String
    let target_language: String
    let user_language: String
    let situation: String?
    let sentence: String?
}

struct GetSimilarWordsResponse: Codable {
    let success: Bool
    let message: String?
    let data: SimilarWordsData?
    let error: String?
}

struct SimilarWordsData: Codable {
    let word: String
    let similar_words: [SimilarWord]?
}

struct SimilarWord: Codable, Identifiable {
    var id: String { word }
    let word: String
    let meaning: String
    let pronunciation: String?
    let example_sentence: String?
    let similarity_score: Double?
    let context: String?
}
