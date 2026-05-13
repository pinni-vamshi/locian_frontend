//
//  ContentAnalyzer.swift
//  locian
//
//  Decides which bricks are present in a pattern's solution.
//
//  Strategy: lexical substring matching with normalization (diacritic-insensitive,
//  case-insensitive, punctuation-stripped, word-boundary-safe). A brick belongs to a
//  pattern only if its target form appears in the pattern's target sentence OR its
//  native meaning appears in the pattern's native sentence. No semantic similarity,
//  no cosine fuzz — bricks bleed across patterns only when they truly share words.
//

import Foundation

class ContentAnalyzer {

    /// Returns every brick that lexically appears in the pattern's text/meaning,
    /// each with score = 1.0 (binary presence). Score is preserved as a Double so
    /// downstream callers (cliff filter, MCQ ranking) keep their existing API.
    nonisolated static func findRelevantBricksWithSimilarity(
        in text: String,
        meaning: String,
        bricks: BricksData?,
        targetLanguage: String,
        nativeLanguage: String = "en"
    ) -> [(id: String, score: Double)] {
        let all = (bricks?.constants ?? []) + (bricks?.variables ?? []) + (bricks?.structural ?? [])
        guard !all.isEmpty else { return [] }

        let normalizedTarget = normalize(text)
        let normalizedMeaning = normalize(meaning)

        var discovered: [(id: String, score: Double)] = []
        for brick in all {
            let targetForm = normalize(brick.word)
            let meaningForm = normalize(brick.meaning)

            let targetMatch = !targetForm.isEmpty && normalizedTarget.contains(targetForm)
            let meaningMatch = !meaningForm.isEmpty && normalizedMeaning.contains(meaningForm)

            if targetMatch || meaningMatch {
                // Per-brick teach-weight from `BrickImportanceService`
                // (computed once at sentence-generation time, stored on the
                // brick). Falls back to 1.0 only when the score is missing,
                // preserving the old behavior for unscored sentences.
                let weight = brick.importance ?? 1.0
                discovered.append((id: brick.id, score: weight))
            }
        }

        return discovered
    }

    /// ID-only convenience.
    nonisolated static func findRelevantBricks(
        in text: String,
        meaning: String,
        bricks: BricksData?,
        targetLanguage: String,
        nativeLanguage: String = "en"
    ) -> [String] {
        return findRelevantBricksWithSimilarity(
            in: text,
            meaning: meaning,
            bricks: bricks,
            targetLanguage: targetLanguage,
            nativeLanguage: nativeLanguage
        ).map { $0.id }
    }

    // MARK: - Normalization

    /// Lower-cases, strips diacritics, collapses non-letter/digit characters into
    /// single spaces, and pads with leading/trailing spaces so substring containment
    /// implicitly enforces word boundaries (e.g. " y " won't match " hoy ").
    nonisolated private static func normalize(_ raw: String) -> String {
        let folded = raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        var buffer = ""
        buffer.reserveCapacity(folded.count + 2)
        var lastWasSpace = true
        buffer.append(" ")
        for scalar in folded.unicodeScalars {
            if CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar) {
                buffer.unicodeScalars.append(scalar)
                lastWasSpace = false
            } else if !lastWasSpace {
                buffer.append(" ")
                lastWasSpace = true
            }
        }
        if !buffer.hasSuffix(" ") {
            buffer.append(" ")
        }
        return buffer
    }
}
