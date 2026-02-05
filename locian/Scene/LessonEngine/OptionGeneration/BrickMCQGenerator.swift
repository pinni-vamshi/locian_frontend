//
//  BrickMCQGenerator.swift
//  locian
//
//  Logic for generating MCQ options for Brick/Component Drills.
//

import Foundation

class BrickMCQGenerator {
    
    /// Generate L2 distractor options for a brick target
    static func generateOptions(target: String, bricks: BricksData?, targetLanguage: String, validator: NeuralValidator?) -> [String] {
        var candidates: [String] = []
        if let bricks = bricks {
             candidates.append(contentsOf: bricks.constants?.map { $0.word } ?? [])
             candidates.append(contentsOf: bricks.variables?.map { $0.word } ?? [])
             candidates.append(contentsOf: bricks.structural?.map { $0.word } ?? [])
        }
        
        return MCQOptionGenerator.generateOptions(
            target: target,
            candidates: candidates,
            targetLanguage: targetLanguage,
            validator: validator
        )
    }
    
    /// Generate Native (L1) options for a brick target meaning
    static func generateNativeOptions(targetMeaning: String, bricks: BricksData?, validator: NeuralValidator?) -> [String] {
        var candidates: [String] = []
        if let bricks = bricks {
             candidates.append(contentsOf: bricks.constants?.map { $0.meaning } ?? [])
             candidates.append(contentsOf: bricks.variables?.map { $0.meaning } ?? [])
             candidates.append(contentsOf: bricks.structural?.map { $0.meaning } ?? [])
        }
        
        return MCQOptionGenerator.generateNativeOptions(
            targetMeaning: targetMeaning,
            candidates: candidates,
            validator: validator
        )
    }
}
