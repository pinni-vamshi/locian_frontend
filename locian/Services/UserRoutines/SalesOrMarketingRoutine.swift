import Foundation
import Combine

struct SalesOrMarketingRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Bedroom", "Home Office", "Hotel Room", "Late Research", "Updating CRM", "Checking LinkedIn", "Lying in Bed", "Quiet Room"],
            1: ["Bedroom", "Sleeping", "Hotel Room", "Resting", "Deep Sleep", "Quiet House", "Dark Room", "Napping"],
            2: ["Bedroom", "Sleeping", "Hotel Room", "Deep Sleep", "Resting", "Recharging", "Stillness", "Comfortable Bed"],
            3: ["Bedroom", "Sleeping", "Hotel Room", "Resting", "Deep Sleep", "Under Blanket", "Warm Bed", "Quiet"],
            4: ["Bedroom", "Sleeping", "Early Flight", "Hotel Room", "Alarm Ringing", "Taking Shower", "Drinking Coffee", "Packing Bag"],
            5: ["Gym", "Taking Shower", "Kitchen", "Coffee Shop", "Listening Podcast", "Motivation", "Checking Mirror", "Checking Outfit"],
            6: ["Kitchen", "Commuting", "Car", "Coffee Shop", "Emailing", "Social Media", "Checking News", "Eating Breakfast"],
            7: ["Client Office", "Cafe", "Commuting", "Phone Call", "Using Headset", "Traffic", "Prepping", "Parking Car"],
            8: ["Client Office", "Meeting Room", "Showroom", "Coffee Shop", "Lobby", "Reception", "Handshaking", "Smiling"],
            9: ["Client Meeting", "Presentation Room", "Lobby", "Cafe", "Demoing Product", "Showing Product", "Brochure", "Using iPad"],
            10: ["Client Office", "Phone Booth", "Car", "Co-working Space", "Cold Calling", "Following Up", "Emailing", "Messaging"],
            11: ["Meeting Room", "Lunch Meeting", "Restaurant", "Office", "Team Sync", "Pipeline Review", "Whiteboard", "Setting Goals"],
            12: ["Restaurant", "Client Lunch", "Cafe", "Food Court", "Eating Sushi", "Eating Salad", "Networking", "Splitting Bill"],
            13: ["Car", "Client Office", "Phone Call", "Office Desk", "GPS", "Traffic", "Podcast", "Voicemail"],
            14: ["Showroom", "Client Meeting", "Presentation", "Office", "Demo Area", "Displaying", "Q&A Session", "Closing Deal"],
            15: ["Coffee Shop", "Networking", "Office Lounge", "Desk", "Drinking Espresso", "Laptop", "Business Card", "LinkedIn"],
            16: ["Meeting Room", "Team Huddle", "Office", "Phone Booth", "Ringing Bell", "High Five", "Sales Gong", "Wrap Up"],
            17: ["Commuting", "Car", "Happy Hour", "Event Space", "Bar", "Cocktail", "Networking", "Socializing"],
            18: ["Networking Event", "Dinner", "Gym", "Home", "Restaurant", "Client Dinner", "Drinking Wine", "Eating Steak"],
            19: ["Restaurant", "Client Dinner", "Kitchen", "Living Room", "Uber", "Home Base", "Shoes Off", "Sofa"],
            20: ["Living Room", "Home Office", "Laptop", "Relaxing", "TV", "Netflix", "Family Time", "Couch"],
            21: ["Living Room", "Bedroom", "Reading", "TV", "Reading Book", "Kindle", "Sales Blog", "Inspiration"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Social Media", "Instagram", "Twitter", "Alarm", "Sleeping"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dark Room", "Quiet House", "Falling Asleep", "Recharging"]
        ]
    }
}
