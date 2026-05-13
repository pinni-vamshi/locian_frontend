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

/// Place categories available for onboarding selection.
/// Synced with backend's places_probability definitions.
struct PlaceCategoryMapping {

    struct PlaceCategory: Identifiable, Hashable {
        let id: String
        let displayName: String
        let icon: String
    }

    static let allPlaces: [PlaceCategory] = [
        PlaceCategory(id: "home", displayName: "Home", icon: "house.fill"),
        PlaceCategory(id: "office", displayName: "Office", icon: "building.2.fill"),
        PlaceCategory(id: "cafe", displayName: "Cafe", icon: "cup.and.saucer.fill"),
        PlaceCategory(id: "restaurant", displayName: "Restaurant", icon: "fork.knife"),
        PlaceCategory(id: "supermarket", displayName: "Supermarket", icon: "cart.fill"),
        PlaceCategory(id: "park", displayName: "Park", icon: "leaf.fill"),
        PlaceCategory(id: "hospital", displayName: "Hospital", icon: "cross.case.fill"),
        PlaceCategory(id: "pharmacy", displayName: "Pharmacy", icon: "pills.fill"),
        PlaceCategory(id: "bank", displayName: "Bank", icon: "banknote.fill"),
        PlaceCategory(id: "airport", displayName: "Airport", icon: "airplane"),
        PlaceCategory(id: "hotel", displayName: "Hotel", icon: "bed.double.fill"),
        PlaceCategory(id: "bus_stop", displayName: "Bus Stop", icon: "bus.fill"),
        PlaceCategory(id: "train_station", displayName: "Train Station", icon: "tram.fill"),
        PlaceCategory(id: "salon", displayName: "Salon", icon: "scissors"),
        PlaceCategory(id: "corner_store", displayName: "Corner Store", icon: "storefront.fill"),
        PlaceCategory(id: "gym", displayName: "Gym", icon: "figure.run"),
        PlaceCategory(id: "university", displayName: "University", icon: "graduationcap.fill"),
        PlaceCategory(id: "library", displayName: "Library", icon: "books.vertical.fill"),
        PlaceCategory(id: "shopping_mall", displayName: "Shopping Mall", icon: "bag.fill"),
        PlaceCategory(id: "movie_theatre", displayName: "Movie Theatre", icon: "film.fill"),
    ]

    static let minimumSelection = 5
}
