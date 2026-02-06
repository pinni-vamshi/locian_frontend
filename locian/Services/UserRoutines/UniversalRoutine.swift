import Foundation
import Combine

struct UniversalRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            // Late Night / Early Morning (0:00 - 4:00)
            0: ["Home", "Bedroom", "Bed", "Sleeping"],
            1: ["Bedroom", "Bed", "Sleeping", "Resting"],
            2: ["Bedroom", "Bed", "Sleeping", "Resting"],
            3: ["Bedroom", "Bed", "Sleeping", "Resting"],
            4: ["Bedroom", "Bed", "Sleeping", "Waking Up"],
            
            // Early Morning (5:00 - 7:00)
            5: ["Bedroom", "Bathroom", "Kitchen", "Home"],
            6: ["Kitchen", "Breakfast", "Home", "Coffee"],
            7: ["Home", "Bathroom", "Bedroom", "Getting Ready"],
            
            // Morning Commute (8:00 - 9:00)
            8: ["Transport", "Car", "Bus", "Train"],
            9: ["Workplace", "Office", "Desk", "Arriving"],
            
            // Mid-Morning (10:00 - 11:00)
            10: ["Workplace", "Desk", "Office", "Working"],
            11: ["Workplace", "Desk", "Meeting", "Coffee Break"],
            
            // Lunch (12:00 - 13:00)
            12: ["Lunch", "Cafe", "Restaurant", "Park"],
            13: ["Lunch", "Cafe", "Walking", "Resting"],
            
            // Afternoon (14:00 - 16:00)
            14: ["Workplace", "Desk", "Office", "Working"],
            15: ["Workplace", "Desk", "Meeting", "Working"],
            16: ["Workplace", "Desk", "Office", "Tea Break"],
            
            // Late Afternoon / Evening (17:00 - 18:00)
            17: ["Workplace", "Desk", "Office", "Leaving"],
            18: ["Transport", "Car", "Bus", "Train"],
            
            // Evening (19:00 - 21:00)
            19: ["Home", "Living Room", "Kitchen", "Dinner"],
            20: ["Home", "Dinner", "Kitchen", "Living Room"],
            21: ["Living Room", "Home", "TV", "Relaxing"],
            
            // Night (22:00 - 23:00)
            22: ["Home", "Living Room", "Bedroom", "Bathroom"],
            23: ["Bedroom", "Bed", "Bathroom", "Sleeping"]
        ]
    }
}
