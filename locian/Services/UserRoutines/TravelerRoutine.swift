import Foundation
import Combine

struct TravelerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Hostel", "Hotel Room", "Night Train", "Airport", "Sleep Pod", "Lobby", "Hammock", "Bunk Bed", "Camping"],
            1: ["Hostel Dorm", "Hotel Bed", "Bus", "In Transit", "Night Flight", "Rest Area", "Sleeping Bag", "Reclining Seat"],
            2: ["Lying in Bed", "Sleeping", "Train Seat", "Airplane Seat", "Waiting Room", "Lounge", "Ferry Cabin", "Quiet Car"],
            3: ["Lying in Bed", "Sleeping", "Deep Sleep", "Resting", "Nappping", "Quiet Zone", "Wearing Earplugs", "Wearing Mask"],
            4: ["Lying in Bed", "Sleeping", "Sunrise View", "Early Start", "Taking Shower", "Packing", "Backpack", "Hiking Boots"],
            5: ["Hostel Common Room", "Taking Shower", "Hotel Gym", "Walking", "Balcony", "Lobby", "Coffee Machine", "Checking Map"],
            6: ["Cafe", "Bakery", "Street Food", "Train Station", "Metro", "Bike Rental", "Scooter", "Ticket Kiosk"],
            7: ["Train Station", "Bus Station", "Walking Tour", "Landmark", "Metro", "Biking", "City Square", "Meeting Point"],
            8: ["Museum", "Historical Site", "Park", "Ticket Text", "Metro Station", "Bike Path", "Audio Guide", "Queue"],
            9: ["Museum Gallery", "Tour Bus", "City Square", "Cafe", "Metro", "Bike Tour", "Taking Photos", "Souvenir Stand"],
            10: ["Landmark", "Viewpoint", "Market", "Street", "Metro", "Biking", "Hidden Gem", "Local Shop"],
            11: ["Market", "Shop", "Cafe", "Park", "Street Performer", "Plaza", "Fountain", "Bench"],
            12: ["Restaurant", "Street Food Stall", "Picnic Spot", "Food Court", "Market Stall", "Cafe Terrace", "Food Truck", "Tasting Food"],
            13: ["Park", "Museum", "Gallery", "Beach", "Bike Ride", "Metro", "Boat Tour", "River Bank"],
            14: ["Beach", "Hiking Trail", "City Walk", "Cafe", "Rent-a-Bike", "Metro Station", "Lockers", "Info Desk"],
            15: ["Cafe", "Gelato Shop", "Souvenir Shop", "Rest Stop", "Bike Rack", "Metro Exit", "Writing Postcard", "Wi-Fi Spot"],
            16: ["Viewpoint", "Sunset Spot", "Bar", "Hostel Lounge", "Rooftop Bar", "Bridge", "Golden Hour", "Camera"],
            17: ["Bar", "Restaurant", "Street Market", "Hostel", "Metro", "Bike Return", "Happy Hour", "Craft Beer"],
            18: ["Restaurant", "Night Market", "Live Music Venue", "Hostel Kitchen", "Metro", "Walking", "Food Crawl", "Tasting Food"],
            19: ["Night Market", "Bar", "Club", "Common Room", "Street Performance", "Plaza", "Dance Floor", "Beer Garden"],
            20: ["Common Room", "Socializing", "Bar", "Live Music", "Lounge", "Games Room", "Pool Table", "Meeting Friends"],
            21: ["Hostel Bar", "Night Club", "Street Walk", "Hotel Room", "Metro", "Taxi", "Uber", "Late Snack"],
            22: ["Hostel Dorm", "Lying in Bed", "Packing", "Journaling", "Sorting Photos", "Calling Home", "Laundry", "Charging Phone"],
            23: ["Lying in Bed", "Sleeping", "Resting", "Planning", "Reading", "Checking Map", "Setting Alarm", "Guidebook"]
        ]
    }
}
