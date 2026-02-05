import Foundation
import Combine

struct NurseRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Hospital Ward", "Nurses Station", "Patient Room", "Break Room", "Night Shift", "Charting", "Checking Vitals", "Coffee"],
            1: ["Patient Room", "Nurses Station", "Hallway", "Medicine Room", "Quiet", "Checking IV", "Call Button", "Flashlight"],
            2: ["Nurses Station", "Quiet Ward", "Break Room", "Charting", "Snack", "Water", "Checking Phone", "Resting"],
            3: ["Patient Room", "Checking Vitals", "Nurses Station", "Hallway", "Pager", "Rounds", "Observing", "Reporting"],
            4: ["Nurses Station", "Report", "Break Room", "Patient Room", "Handover", "Notes", "Uniform", "Ready to Leave"],
            5: ["Locker Room", "Commuting", "Car", "Bus Stop", "Sunrise", "Changing Shoes", "Radio", "Home"],
            6: ["Home", "Bedroom", "Shower", "Kitchen", "Breakfast", "Blackout Curtains", "Pajamas", "Sleep Mask"],
            7: ["Bedroom", "Lying in Bed", "Sleeping", "Blackout Curtains", "Earplugs", "Silence", "Dark Room", "Resting"],
            8: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Recharging", "Stillness", "Comfort"],
            9: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Resting", "Quiet", "Pillow", "Blanket"],
            10: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Peace", "Heavy Sleep", "Recovering", "Sleeping"],
            11: ["Bedroom", "Lying in Bed", "Sleeping", "Waking Up", "Alarm", "Stretching", "Water", "Coffee"],
            12: ["Kitchen", "Breakfast", "Living Room", "Garden", "Sunshine", "Meal Prep", "Lunch", "Relaxing"],
            13: ["Living Room", "Relaxing", "Errands", "Gym", "Yoga", "Grocery Store", "Bank", "Park"],
            14: ["Gym", "Shower", "Grocery Store", "Kitchen", "Cooking", "Cleaning", "Laundry", "Podcast"],
            15: ["Kitchen", "Meal Prep", "Living Room", "Napping", "Couch", "TV", "Reading Book", "Resting"],
            16: ["Bedroom", "Napping", "Resting", "Alarm", "Getting Ready", "Scrubs", "Shoes", "Badge"],
            17: ["Shower", "Kitchen", "Coffee", "Commuting", "Car", "Traffic", "Hospital Parking", "Entrance"],
            18: ["Hospital Locker Room", "Briefing Room", "Nurses Station", "Ward", "Handover", "Report", "Assignments", "Team"],
            19: ["Patient Room", "Medication Round", "Nurses Station", "Hallway", "Cart", "Scanner", "Water Pitcher", "Pills"],
            20: ["Patient Room", "Charting", "Nurses Station", "Triage", "Computer", "Phone Call", "Doctor", "Family"],
            21: ["Patient Room", "Ward", "Break Room", "Nurses Station", "Dinner", "Coffee", "Chatting", "Resting"],
            22: ["Patient Room", "Night Check", "Hallway", "Nurses Station", "Quiet", "Dim Lights", "Sleeping Patient", "Monitor"],
            23: ["Nurses Station", "Charting", "Break Room", "Patient Room", "Stocking", "Cleaning", "Organizing", "Reviewing"]
        ]
    }
}
