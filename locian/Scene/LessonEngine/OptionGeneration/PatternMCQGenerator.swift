//
//  PatternMCQGenerator.swift
//  locian
//
//  Logic for generating MCQ options for Pattern Drills.
//

import Foundation

class PatternMCQGenerator {
    
    /// Generate L2 distractor options for a pattern target
    static func generateOptions(target: String, allDrills: [DrillState], targetLanguage: String, validator: NeuralValidator?) -> [String] {
        // Filter to only pattern drills (exclude brick drills that start with "INT-")
        let patternDrills = allDrills.filter { !$0.id.hasPrefix("INT-") }
        let patternCandidates = patternDrills.map { $0.drillData.target }
        
        return MCQOptionGenerator.generateOptions(
            target: target,
            candidates: patternCandidates,
            targetLanguage: targetLanguage,
            validator: validator
        )
    }
    
    /// Generate Native (L1) options for a pattern target meaning
    static func generateNativeOptions(targetMeaning: String, allDrills: [DrillState], validator: NeuralValidator?) -> [String] {
        // Filter to only pattern drills (exclude brick drills that start with "INT-")
        let patternDrills = allDrills.filter { !$0.id.hasPrefix("INT-") }
        let candidates = patternDrills.map { $0.drillData.meaning }
        
        return MCQOptionGenerator.generateNativeOptions(
            targetMeaning: targetMeaning,
            candidates: candidates,
            validator: validator
        )
    }
}
