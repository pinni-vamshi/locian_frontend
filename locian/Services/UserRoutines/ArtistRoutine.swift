import Foundation

struct ArtistRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Studio", "Home Office", "Living Room", "Working Late", "Painting", "Stretching Canvas", "Listening to Music", "Relaxing"],
            1: ["Studio", "Bedroom", "Late Sketching", "Lying in Bed", "Brainstorming", "Drawing", "Having Idea", "Quiet Room"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Deep Sleep", "Napping", "Resting Eyes", "Resting", "Recharging"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Quiet", "Dark Room", "Comfortable Bed"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Morning Light", "Waking Up", "Turning Over", "Cozy Bed"],
            5: ["Bedroom", "Lying in Bed", "Sleeping", "Early Inspiration", "Journaling", "Stretching", "Boiling Water", "Looking Outside"],
            6: ["Kitchen", "Making Coffee", "Studio", "Garden", "Drinking Espresso", "Drawing Pad", "Walking", "Morning Dew"],
            7: ["Studio", "Easle Area", "Sketching", "Morning Light", "Mixing Paint", "Preparing Palette", "Radio", "Wearing Apron"],
            8: ["Studio", "Art Store", "Park", "Walking Outside", "Bus Ride", "Observing People", "Taking Photos", "Texture Hunting"],
            9: ["Studio", "Painting", "Work Table", "Gallery", "Brush Stroke", "Layering Paint", "Drying Canvas", "Smelling Turpentine"],
            10: ["Studio", "Creative Zone", "Music Corner", "Window Seat", "Playing Records", "Natural Light", "Focusing", "Working"],
            11: ["Studio", "Work Desk", "Digital Tablet", "Meeting", "Using Stylus", "Using Photoshop", "Client Call", "Portfolio Update"],
            12: ["Kitchen", "Cafe", "Park Bench", "Eating Lunch", "Eating Sandwich", "Coffee Refill", "People Watching", "Sketching Napkin"],
            13: ["Studio", "Gallery Visit", "Museum", "Workshop", "Finding Inspiration", "Writing Notes", "Critiquing", "Sculpture Garden"],
            14: ["Studio", "Prep Work", "Work Table", "Outdoor Sketching", "Stretching Canvas", "Framing Art", "Charcoal Dust", "Sharpening Pencil"],
            15: ["Studio", "Cleaning Up", "Photography Area", "Desk", "Washing Brushes", "Wiping Hands", "Using Tripod", "Posting Art"],
            16: ["Gallery", "Networking Event", "Coffee Shop", "Studio", "Drinking Wine", "Handshaking", "Sharing Card", "Talking Art"],
            17: ["Art Store", "Post Office", "Commuting", "Home", "Mailing Package", "Printing Label", "Subway", "Listening Podcast"],
            18: ["Kitchen", "Living Room", "Relaxing", "Social Gathering", "Cooking", "Chopping Veggies", "Listening Music", "Meeting Friends"],
            19: ["Dinner Table", "Restaurant", "Friend's House", "Living Room", "Sharing Meal", "Laughing", "Drinking Wine", "Discussing Art"],
            20: ["Living Room", "Sketching", "Movie", "Relaxing", "Researching", "Watching Film", "Couch", "Using Tablet"],
            21: ["Studio", "Late Idea", "Reading", "Bedroom", "Quick Sketch", "Taking Notes", "Reading Book", "Desk Lamp"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Journaling", "Washing Face", "Reflecting", "Gratitude", "Pajamas"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Falling Asleep", "Drifting Off", "Resting Eyes", "Quiet House", "Resting"]
        ]
    }
}
