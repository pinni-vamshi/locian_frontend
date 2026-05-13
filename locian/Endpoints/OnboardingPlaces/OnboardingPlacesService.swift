//
//  OnboardingPlacesService.swift
//  locian
//
//  Sends selected place categories to backend for temporal bucket pre-population.
//

import Foundation

struct SavePlacesRequest: Codable {
    let selected_places: [String]
}

struct SavePlacesResponse: Codable {
    let success: Bool
    let total_tags: Int?
    let error: String?
}

class OnboardingPlacesService {
    static let shared = OnboardingPlacesService()
    private init() {}

    func savePlaces(places: [String], completion: @escaping (Result<SavePlacesResponse, Error>) -> Void) {
        let request = SavePlacesRequest(selected_places: places)

        BaseAPIManager.shared.performRequest(
            endpoint: "/api/onboarding/save-places",
            method: "POST",
            body: request,
            timeoutInterval: 30.0,
            completion: completion
        )
    }
}
