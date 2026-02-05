import Foundation
import Combine

struct DesignerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Home Office", "Working", "Living Room", "Music Corner", "Headphones", "Typing", "Browsing", "Mood Boarding"],
            1: ["Bedroom", "Lying in Bed", "Late Inspiration", "Sketchbook", "Taking Notes", "Thinking", "Sleeping", "Quiet"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Dreaming", "Seeing Colors", "Resting", "Recharging", "Darkness"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Stillness", "Comfort", "Pillow", "Silence"],
            4: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dreaming", "Quiet Room", "Heavy Sleep", "Blanket"],
            5: ["Bedroom", "Lying in Bed", "Sleeping", "Early Light", "Sunrise", "Yoga", "Stretching", "Drinking Water"],
            6: ["Kitchen", "Making Coffee", "Patio", "Living Room", "Espresso", "Reading Blog", "Scrolling", "Inspired"],
            7: ["Home Office", "Desk", "Pinning Ideas", "Yoga Mat", "Emailing", "Slack", "Listing Tasks", "Music"],
            8: ["Studio", "Desk", "Meeting Room", "Commuting", "Subway", "Podcast", "Office", "Greeting"],
            9: ["Studio", "Design Station", "Whiteboard", "Coffee Shop", "Stand-up", "Using Figma", "Sketching", "Thinking"],
            10: ["Studio", "Critique Room", "Desk", "Focus Pod", "Feedback", "Iterating", "Fixing Pixels", "Grid"],
            11: ["Meeting Room", "Client Call", "Desk", "Lounge", "Presentation", "Deck", "Taking Notes", "Zoom"],
            12: ["Cafe", "Park Bench", "Museum", "Lunch Spot", "Eating Salad", "Sandwich", "Sunshine", "People Watching"],
            13: ["Studio", "Desk", "Workshop", "Testing Materials", "Swatch", "Feeling Texture", "Color Palette", "Sampling"],
            14: ["Studio", "Focus Time", "Desk", "Quiet Room", "Headphones On", "Deep Work", "Flow", "Creating"],
            15: ["Meeting Room", "Brainstorming", "Lounge", "Desk", "Sticky Notes", "Sharpie", "Whiteboard", "Team"],
            16: ["Studio", "Wrap Up", "Desk", "Showroom", "Saving Files", "Exporting", "Backup", "Cleaning Desk"],
            17: ["Gallery", "Event Space", "Commuting", "Bar", "Opening", "Viewing Art", "Drinking", "Networking"],
            18: ["Gym", "Yoga Studio", "Park", "Home", "Running", "Walking", "Fresh Air", "Prep Dinner"],
            19: ["Kitchen", "Eating Dinner", "Living Room", "Sketchbook", "Cooking", "Drinking Wine", "Listening Music", "Relaxing"],
            20: ["Living Room", "Watching Movie", "Relaxing", "Home Office", "Researching", "Film", "Composing", "Couch"],
            21: ["Home Office", "Personal Project", "Bedroom", "Reading", "Portfolio", "Website", "Blogging", "Reading Book"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Pinterest", "Scrolling", "Inspiration", "Washing Face", "Sleeping"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Dreaming", "Resting", "Darkness", "Recharging", "Ideas"]
        ]
    }
}
