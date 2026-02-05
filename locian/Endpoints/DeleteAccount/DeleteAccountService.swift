//
//  DeleteAccountService.swift
//  locian
//

import Foundation

class DeleteAccountService {
    static let shared = DeleteAccountService()
    private init() {}
    
    func deleteAccount(sessionToken: String, completion: @escaping (Result<DeleteAccountResponse, Error>) -> Void) {
        let request = DeleteAccountRequest(session_token: sessionToken)
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/delete",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
