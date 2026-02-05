import SwiftUI
import Combine

class ProfileLogic: ObservableObject {
    @ObservedObject var appState: AppStateManager
    @Published var isUpdatingProfession = false
    @Published var professionUpdateError: String? = nil
    
    init(appState: AppStateManager) {
        self.appState = appState
    }
    
    let professionOptions = [
        "student", "software_engineer", "teacher", "doctor", "artist",
        "business_professional", "sales_or_marketing", "traveler", "homemaker",
        "chef", "police", "bank_employee", "nurse", "designer", "engineer_manager",
        "photographer", "content_creator", "other"
    ]
    
    func updateProfession(to profession: String) {
        guard !isUpdatingProfession && profession != appState.profession else { return }
        isUpdatingProfession = true
        appState.updateProfession(to: profession) { [weak self] success, message in
            DispatchQueue.main.async {
                self?.isUpdatingProfession = false
                if !success { self?.professionUpdateError = message }
            }
        }
    }
}
