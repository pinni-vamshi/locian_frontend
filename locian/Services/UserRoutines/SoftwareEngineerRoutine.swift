import Foundation
import Combine

struct SoftwareEngineerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Home Office", "Gaming Station", "Living Room", "Chatting Online", "Typing Code", "Dual Monitors", "Server Room", "Quiet Corner"],
            1: ["Bedroom", "Lying in Bed", "Late Night Coding", "Home Office", "Browsing Web", "Social Media", "Night Mode", "Kitchen"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Deep Sleep", "Napping", "Late Night", "Dark Room", "Resting"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Snoozing", "Comfortable Bed", "Night Time"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Quiet Room", "Resting", "Sleeping", "Early Morning", "Checking Alarm"],
            5: ["Bedroom", "Lying in Bed", "Waking Up", "Gym", "Yoga Corner", "Running Outside", "Kitchen", "Making Coffee"],
            6: ["Gym", "Home Gym", "Bathroom", "Kitchen", "Listening to Podcast", "Taking Shower", "Drinking Shake", "Checking News"],
            7: ["Kitchen", "Coffee Station", "Breakfast Table", "Taking Shower", "Commuting", "Riding Train", "Driving Car", "Listening to Audio"],
            8: ["Commuting", "Home Office", "Train Station", "Driving Car", "Carrying Bag", "Security Gate", "Riding Elevator", "Coffee Shop"],
            9: ["Office Desk", "Stand-up Meeting", "Conference Room", "Home Office", "Video Call", "Messaging Team", "Reviewing Board", "Looking at Monitor"],
            10: ["Office Desk", "Code Review", "Focus Room", "Coffee Machine", "Listening to Music", "Writing Code", "Using Terminal", "Commiting Code"],
            11: ["Meeting Room", "Office Desk", "Zoom Call", "Whiteboard Area", "Pair Programming", "Writing Specs", "Designing Architecture", "Manager's Office"],
            12: ["Cafeteria", "Office Kitchen", "Nearby Restaurant", "Food Truck", "Salad Spot", "Sushi Bar", "Park Bench", "Office Lounge"],
            13: ["Office Desk", "Focus Pod", "Coding Station", "Fixing Bugs", "Searching Help", "Debugging", "Reading Logs", "Drinking Energy Drink"],
            14: ["Meeting Room", "Sprint Planning", "Office Lounge", "Desk", "Retro Board", "Voting", "Writing Notes", "Projector Screen"],
            15: ["Office Desk", "Pair Programming", "Coffee Break", "Snack Bar", "Ping Pong Area", "Water Cooler", "Walking Hallway", "Window View"],
            16: ["Meeting Room", "Office Desk", "Whiteboard", "Manager's Office", "One-on-One", "Feedback Session", "Career Chat", "Setting Goals"],
            17: ["Commuting", "Home Office", "Bus Stop", "Driving Car", "Traffic Jam", "Listening Podcast", "Bike Lane", "Walking Path"],
            18: ["Gym", "Running Path", "Living Room", "Kitchen", "Grocery Store", "Package Pickup", "Checking Mailbox", "Entering Home"],
            19: ["Kitchen", "Dinner Table", "Living Room", "Restaurant", "Ordering Food", "Cooking Dinner", "Drinking Wine", "Watching TV"],
            20: ["Living Room", "Gaming Setup", "Home Office", "Sitting on Sofa", "Playing Games", "Game Console", "Chatting", "Streaming Video"],
            21: ["Home Office", "Side Project", "Reading Nook", "Bedroom", "Pushing Code", "Writing Blog", "Watching Tutorial", "Reading Book"],
            22: ["Bathroom", "Bedroom", "Lying in Bed", "Reading News", "Tech News", "Group Chat", "Setting Alarm", "Charging Phone"],
            23: ["Bedroom", "Lying in Bed", "Winding Down", "Sleeping", "Meditating", "White Noise", "Falling Asleep", "Dark Room"]
        ]
    }
}
