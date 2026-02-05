import Foundation
import Combine

struct OtherRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Bedroom", "Lying in Bed", "Living Room", "Home Office", "Late Night", "Reading", "Watching TV", "Quiet"],
            1: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Quiet House", "Pillow", "Darkness", "Dreaming"],
            2: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Stillness", "Recharging", "Comfort", "Blanket"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Dreaming", "Silence", "Night", "Resting", "Peace"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Early Morning", "Turning Over", "Snoozing", "Dreams"],
            5: ["Bedroom", "Waking Up", "Kitchen", "Bathroom", "Making Coffee", "Shower", "Stretching", "News"],
            6: ["Kitchen", "Drinking Coffee", "Living Room", "Garden", "Breakfast", "Radio", "Pet", "Phone"],
            7: ["Commute", "Transport", "Driving Car", "Walking", "Bus", "Train", "Podcast", "Music"],
            8: ["Workplace", "Office", "Desk", "Meeting Point", "Greeting", "Setup", "Coffee", "Starting"],
            9: ["Workplace", "Desk", "Meeting Room", "Station", "Task", "Focusing", "Team", "Chatting"],
            10: ["Workplace", "Break Area", "Desk", "Work Site", "Snack", "Drinking Water", "Discussing", "Planning"],
            11: ["Workplace", "Meeting", "Desk", "Task Area", "Collaboration", "Phone", "Emailing", "Reviewing"],
            12: ["Lunch Spot", "Cafe", "Park", "Kitchen", "Eating Sandwich", "Walking", "Fresh Air", "Relaxing"],
            13: ["Workplace", "Desk", "Meeting", "Site", "Project", "Focusing", "Computer", "Using Tool"],
            14: ["Workplace", "Focus Area", "Desk", "Site", "Creating", "Problem Solving", "Meeting", "Call"],
            15: ["Workplace", "Break Room", "Desk", "Meeting", "Tea", "Chatting", "Resting", "Planning"],
            16: ["Workplace", "Wrap Up", "Desk", "Exit", "Cleanup", "Summarizing", "Goodbye", "Packing"],
            17: ["Commuting", "Transport", "Shop", "Errands", "Grocery", "Bank", "Car", "Walking"],
            18: ["Home", "Living Room", "Kitchen", "Gym", "Workout", "Dinner Prep", "Relaxing", "Family"],
            19: ["Dinner Table", "Kitchen", "Living Room", "Relaxing", "Meal", "Conversation", "TV", "Couch"],
            20: ["Living Room", "Relaxing", "Hobby Area", "Reading", "Movie", "Game", "Music", "Crafting"],
            21: ["Living Room", "TV", "Bedroom", "Bath", "Watching Show", "Reading Book", "Winding Down", "Tea"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Routine", "Washing Face", "Teeth", "Pajamas", "Sleeping"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Darkness", "Silence", "Dreaming", "Recharging"]
        ]
    }
}
