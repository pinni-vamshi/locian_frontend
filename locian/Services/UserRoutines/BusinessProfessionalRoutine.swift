import Foundation

struct BusinessProfessionalRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Hotel Room", "Home Bedroom", "Sending Emails", "Airport Lounge", "Charging Phone", "Quiet Car", "Minibar", "Lying in Bed"],
            1: ["Hotel Room", "Bedroom", "Sleeping", "Flight", "Wearing Mask", "Wearing Earplugs", "Do Not Disturb", "Resting"],
            2: ["Hotel Room", "Bedroom", "Sleeping", "Resting", "Deep Sleep", "Quiet Room", "Dark Room", "Recharging"],
            3: ["Hotel Room", "Bedroom", "Sleeping", "Resting", "Deep Sleep", "Comfortable Bed", "Hotel Bed", "Napping"],
            4: ["Hotel Room", "Bedroom", "Deep Sleep", "Early Flight", "Wake Up Call", "Taking Shower", "Packing Bag", "Drinking Coffee"],
            5: ["Hotel Gym", "Home Gym", "Taking Shower", "Airport", "Check-in", "Security Line", "Lounge Access", "Pulling Suitcase"],
            6: ["Airport Lounge", "Kitchen", "Coffee Shop", "Taxi", "Rideshare", "Checking News", "Drinking Espresso", "Boarding Gate"],
            7: ["Commuting", "Train", "Taxi", "Airport Gate", "Flight Mode", "Using Laptop", "Reviewing Deck", "Fastening Belt"],
            8: ["Office Lobby", "Conference Room", "Cafe", "Desk", "Scanning Badge", "Elevator Pitch", "Handshaking", "Morning Huddle"],
            9: ["Conference Room", "Meeting", "Desk", "Client Office", "Whiteboard", "Zoom Call", "Taking Notes", "Drinking Water"],
            10: ["Conference Room", "Video Call Booth", "Coffee Station", "Boardroom", "Using Projector", "Presenting", "Discussing Agenda", "Action Items"],
            11: ["Meeting Room", "Desk", "Client Office", "Lobby", "Networking", "Giving Card", "Checking LinkedIn", "Closing Deal"],
            12: ["Restaurant", "Business Lunch", "Cafe", "Office Kitchen", "Steakhouse", "Sushi Bar", "Quiet Table", "Paying Bill"],
            13: ["Desk", "Conference Call", "Taxi", "Client Site", "Uber", "Laptop Bag", "Charging Phone", "Emailing"],
            14: ["Meeting Room", "Presentation Hall", "Desk", "Lounge", "Auditorium", "Speaking", "Q&A Session", "Feedback"],
            15: ["Boardroom", "Coffee Break", "Desk", "Phone Booth", "Quick Call", "Texting", "Checking Calendar", "Rescheduling"],
            16: ["Meeting Room", "Wrap-up", "Desk", "Manager's Office", "Making List", "Prioritizing", "Team Chat", "Messaging"],
            17: ["Commuting", "Airport Lounge", "Taxi", "Bar", "Happy Hour", "Networking", "Hotel Lobby", "Checking In"],
            18: ["Networking Event", "Restaurant", "Hotel Lobby", "Home", "Wine Bar", "Eating Appetizers", "Small Talk", "New Contacts"],
            19: ["Restaurant", "Dinner Meeting", "Kitchen", "Living Room", "Room Service", "Hotel TV", "Calling Family", "Relaxing"],
            20: ["Hotel Room", "Living Room", "Home Office", "Laptop", "Expensing", "Cleaning Email", "Watching News", "Sofa"],
            21: ["Hotel Room", "Bedroom", "Reading", "Relaxing", "Reading Kindle", "Business Book", "Podcast", "Unwinding"],
            22: ["Hotel Room", "Bedroom", "Lying in Bed", "Checking News", "Market Watch", "Setting Alarm", "Pajamas", "Sleeping"],
            23: ["Hotel Room", "Bedroom", "Sleeping", "Resting", "Dark Room", "Quiet Room", "Falling Asleep", "Recharging"]
        ]
    }
}
