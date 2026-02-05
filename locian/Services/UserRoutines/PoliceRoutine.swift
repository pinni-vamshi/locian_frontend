import Foundation
import Combine

struct PoliceRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Patrol Car", "Street Corner", "Police Station", "Break Room", "Night Shift", "Using Radio", "Drinking Coffee", "Partner"],
            1: ["Patrol Car", "Quiet Street", "Station Desk", "Writing Report", "Dispatch Call", "Flashlight", "Alley", "Check Point"],
            2: ["Patrol Car", "Highway", "Station", "Break", "Speed Trap", "Rest Stop", "Dashboard", "Silence"],
            3: ["Patrol Car", "Neighborhood", "Station", "Coffee Stop", "24/7 Diner", "Gas Station", "Empty Road", "Watching"],
            4: ["Patrol Car", "Main Street", "Station Lockup", "Desk", "Booking", "Paperwork", "Report", "Quiet"],
            5: ["Patrol Car", "Shift Change", "Locker Room", "Commuting", "Sunrise", "Changing Clothes", "Car", "Home"],
            6: ["Home", "Bedroom", "Shower", "Sleeping", "Blackout Curtains", "Earplugs", "Breakfast", "Family"],
            7: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Deep Sleep", "Silence", "Dark Room", "Recharging"],
            8: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Resting", "Stillness", "Comfort", "Pillow"],
            9: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Quiet House", "Fan", "Blanket", "Sleeping"],
            10: ["Bedroom", "Lying in Bed", "Sleeping", "Waking Up", "Alarm", "Coffee", "Shower", "Wearing Uniform"],
            11: ["Kitchen", "Breakfast", "Gym", "Living Room", "Lifting Weights", "Running", "Meal Prep", "News"],
            12: ["Gym", "Running Track", "Shower", "Kitchen", "Lunch", "Protein Shake", "Relaxing", "TV"],
            13: ["Living Room", "Relaxing", "Errands", "Garden", "Grocery Store", "Bank", "Barber", "Napping"],
            14: ["Kitchen", "Lunch", "Home Office", "Reading", "Study", "Laptop", "Emailing", "Phone Call"],
            15: ["Commuting", "Station", "Locker Room", "Briefing Room", "Uniform On", "Radio Check", "Meeting Partner", "Roll Call"],
            16: ["Patrol Car", "Traffic Stop", "School Zone", "Street", "Intersection", "Community", "Waving", "Radio"],
            17: ["Patrol Car", "Rush Hour Traffic", "Incident Scene", "Street", "Highway", "Accident", "Lights", "Siren"],
            18: ["Patrol Car", "Neighborhood", "Park", "Station", "Foot Patrol", "Community Center", "Shop", "Dinner Break"],
            19: ["Station", "Writing Report", "Break Room", "Booking", "Computer", "Evidence", "Witness", "Interviewing"],
            20: ["Patrol Car", "Commercial District", "Alley", "Street", "Checking Store", "Security", "Radio Call", "Dispatch"],
            21: ["Patrol Car", "Night Patrol", "Bar District", "Station", "Crowd Control", "Club", "Taxi Stand", "Noise Complaint"],
            22: ["Patrol Car", "Quiet Street", "Check Point", "Station", "DUI Check", "Highway", "Pulling Over", "Ticket"],
            23: ["Patrol Car", "Highway", "Incident Scene", "Break Room", "Coffee", "Radio", "Partner", "Watching"]
        ]
    }
}
