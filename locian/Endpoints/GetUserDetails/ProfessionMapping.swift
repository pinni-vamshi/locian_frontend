import Foundation

/// Centralized mapping for user professions and their routine-logic keys.
/// Lives in the GetUserDetails domain.
struct ProfessionMapping {
    static let allProfessions = [
        "student",
        "software_engineer",
        "teacher",
        "doctor",
        "artist",
        "business_professional",
        "sales_or_marketing",
        "traveler",
        "homemaker",
        "chef",
        "police",
        "bank_employee",
        "nurse",
        "designer",
        "engineer_manager",
        "photographer",
        "content_creator",
        "entrepreneur",
        "other"
    ]
}
