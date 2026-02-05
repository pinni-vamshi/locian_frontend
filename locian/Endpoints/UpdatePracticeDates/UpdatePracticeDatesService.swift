//
//  UpdatePracticeDatesService.swift
//  locian
//

import Foundation

class UpdatePracticeDatesService {
    static let shared = UpdatePracticeDatesService()
    private init() {}
    
    func updatePracticeDates(sessionToken: String, targetLanguage: String, practiceDates: [String], completion: @escaping (Result<UpdatePracticeDatesResponse, Error>) -> Void) {
        let request = UpdatePracticeDatesRequest(
            target_language: targetLanguage,
            practice_dates: practiceDates,
            session_token: sessionToken
        )
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/language-pair/update-practice-dates",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
