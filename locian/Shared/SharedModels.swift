//
//  SharedModels.swift
//  locian
//
//  Created to host shared domain models and restore missing types after modularization.
//

import Foundation

// MARK: - Generic API Response
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
    
    var errorMessage: String? { error ?? message }
}

// MARK: - Backward Compatibility Aliases
typealias StudiedPlaceWithSituations = MicroSituationData
typealias GetUserDetailsData = UserDetailsData
