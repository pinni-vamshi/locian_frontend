
import Foundation

extension LocalizationManager {
    func getLocalizedProfession(_ raw: String) -> String {
        let key: StringKey
        switch raw.lowercased() {
        case "student": key = .student
        case "software_engineer": key = .softwareEngineer
        case "teacher": key = .teacher
        case "doctor": key = .doctor
        case "artist": key = .artist
        case "business_professional": key = .businessProfessional
        case "sales_or_marketing": key = .salesOrMarketing
        case "traveler": key = .traveler
        case "homemaker": key = .homemaker
        case "chef": key = .chef
        case "police": key = .police
        case "bank_employee": key = .bankEmployee
        case "nurse": key = .nurse
        case "designer": key = .designer
        case "engineer_manager": key = .engineerManager
        case "photographer": key = .photographer
        case "content_creator": key = .contentCreator
        case "entrepreneur": key = .entrepreneur
        case "other": key = .other
        default: return raw.uppercased()
        }
        return self.string(key).uppercased()
    }
}
