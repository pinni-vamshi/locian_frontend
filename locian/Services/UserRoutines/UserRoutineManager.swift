import Foundation
import Combine

struct UserRoutineManager {
    static func getPlaces(for profession: String, hour: Int) -> [String] {
        // Normalize the profession string to match keys used in the app
        let key = profession.lowercased().replacingOccurrences(of: " ", with: "_")
        
        switch key {
        case "student":
            return StudentRoutine.data[hour] ?? []
        case "software_engineer":
            return SoftwareEngineerRoutine.data[hour] ?? []
        case "teacher":
            return TeacherRoutine.data[hour] ?? []
        case "doctor":
            return DoctorRoutine.data[hour] ?? []
        case "artist":
            return ArtistRoutine.data[hour] ?? []
        case "business_professional":
            return BusinessProfessionalRoutine.data[hour] ?? []
        case "sales_or_marketing":
            return SalesOrMarketingRoutine.data[hour] ?? []
        case "traveler":
            return TravelerRoutine.data[hour] ?? []
        case "homemaker":
            return HomemakerRoutine.data[hour] ?? []
        case "chef":
            return ChefRoutine.data[hour] ?? []
        case "police":
            return PoliceRoutine.data[hour] ?? []
        case "bank_employee":
            return BankEmployeeRoutine.data[hour] ?? []
        case "nurse":
            return NurseRoutine.data[hour] ?? []
        case "designer":
            return DesignerRoutine.data[hour] ?? []
        case "engineer_manager":
            return EngineerManagerRoutine.data[hour] ?? []
        case "photographer":
            return PhotographerRoutine.data[hour] ?? []
        case "content_creator":
            return ContentCreatorRoutine.data[hour] ?? []
        case "entrepreneur":
            return EntrepreneurRoutine.data[hour] ?? []
        default:
            return OtherRoutine.data[hour] ?? []
        }
    }
}
