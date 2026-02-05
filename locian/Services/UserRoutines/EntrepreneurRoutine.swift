import Foundation
import Combine

struct EntrepreneurRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Home Office", "Using Laptop", "Whiteboard", "Late Night Strategy", "Bedroom", "Deep Focus", "Quiet House", "Taking Notes"],
            1: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Meditation App", "Quiet Room", "Winding Down", "Darkness"],
            2: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Dreaming", "Recharging", "Stillness", "Comfort"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Dreaming", "Silence", "Heavy Sleep", "Peace"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Early Thoughts", "Resting", "Dreaming", "Idea Flash", "Turning Over"],
            5: ["Gym", "Running Path", "Meditation Corner", "Kitchen", "Making Coffee", "Journaling", "Gratitude", "Visualization"],
            6: ["Kitchen", "Home Office", "Email Triage", "News", "Coffee Shop", "Morning Plan", "Setting Goals", "Calendar"],
            7: ["Commuting", "Co-working Space", "Cafe", "Driving Car", "Listening Podcast", "Phone Call", "Audiobook", "Growth Mindset"],
            8: ["Co-working Space", "Meeting Room", "Whiteboard", "Desk", "Cafe", "Networking", "Stand-up", "Team"],
            9: ["Investor Meeting", "Conference Room", "Coffee Shop", "Lobby", "Pitch Deck", "Zoom Booth", "Slide", "Feedback"],
            10: ["Team Huddle", "Focus Area", "Product Review", "Desk", "Whiteboard", "Office", "Roadmap", "KPIs"],
            11: ["Meeting Room", "Client Call", "Desk", "Lounge", "Phone Booth", "Strategy Session", "Sales", "Deal"],
            12: ["Restaurant", "Business Lunch", "Cafe", "Networking Event", "Quick Bite", "Park Bench", "Eating Salad", "Handshake"],
            13: ["Co-working Space", "Desk", "Deep Work", "Headphones", "Meeting Room", "Nap Pod", "Focus", "Execution"],
            14: ["Meeting Room", "Demo", "Client Office", "Development", "Desk", "Call", "Prototype", "Testing"],
            15: ["Coffee Shop", "Networking", "Mentor Meeting", "Lounge", "Desk", "Emailing", "Advice", "Connection"],
            16: ["Events Space", "Pitch Practice", "Team Meeting", "Wrap Up", "Desk", "Review", "Metrics", "Celebrating"],
            17: ["Commuting", "Networking Mixer", "Bar", "Event", "Car", "Podcast", "Conversation", "Opportunity"],
            18: ["Gym", "Bar", "Restaurant", "Dinner Meeting", "Home", "Relaxing", "Workout", "Sauna"],
            19: ["Dinner Table", "Kitchen", "Living Room", "Laptop", "Family Time", "News", "Cooking", "Drinking Wine"],
            20: ["Home Office", "Reading", "Planning", "Living Room", "Notebook", "Relaxing", "Biography", "Learning"],
            21: ["Living Room", "Documentary", "Bedroom", "Reading", "Idea Log", "Phone", "Inspiration", "Notes"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Meditation", "Planning Tomorrow", "Sleeping", "Priority List", "Resting"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Audiobook", "Winding Down", "Darkness", "Recharging"]
        ]
    }
}
