import Foundation

struct BankEmployeeRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Quiet House", "Pillow", "Dark Room", "Falling Asleep"],
            1: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Stillness", "Recharging", "Comfort", "Blanket"],
            2: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Silence", "Night", "Resting", "Peace"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Quiet", "Heavy Sleep", "Warmth"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Early Birds", "Turning Over", "Snoozing", "Sleeping"],
            5: ["Bedroom", "Lying in Bed", "Waking Up", "Quiet Time", "Meditation", "Reading", "Coffee", "Sunrise"],
            6: ["Gym", "Shower", "Kitchen", "Breakfast", "Wearing Suit", "Ironing", "News", "Market Watch"],
            7: ["Commuting", "Train", "Car", "Coffee Shop", "Subway", "Podcast", "Newspaper", "Station"],
            8: ["Bank Lobby", "Desk", "Vault", "Office", "Key Card", "Logging In", "Emailing", "Morning Huddle"],
            9: ["Office", "Meeting Room", "Teller Counter", "Desk", "Client Call", "Spreadsheet", "Coffee", "Data Entry"],
            10: ["Office", "Client Meeting", "Conference Room", "Break Room", "Financial Planning", "Loan App", "Signing", "Handshaking"],
            11: ["Desk", "Phone Call", "Office", "Meeting Room", "Zoom", "Headset", "Taking Notes", "Manager"],
            12: ["Restaurant", "Cafe", "Park Bench", "Office Kitchen", "Eating Salad", "Sandwich", "Lunch Buddy", "Walking"],
            13: ["Desk", "Computer", "Office", "Bank Lobby", "Customer", "Transaction", "Approving", "Emailing"],
            14: ["Meeting Room", "Conference Call", "Desk", "Files Room", "Auditing", "Compliance", "Reporting", "Reviewing"],
            15: ["Office", "Client Meeting", "Desk", "Lobby", "Investing", "Portfolio", "Chart", "Proposal"],
            16: ["Meeting Room", "Briefing", "Desk", "Closing Time", "Vault Count", "Locking Up", "System Check", "Wrap Up"],
            17: ["Commuting", "Train", "Gym", "Grocery Store", "Traffic", "Podcast", "Car", "Home"],
            18: ["Kitchen", "Living Room", "Relaxing", "Dinner Prep", "Cooking", "Drinking Wine", "Shoes Off", "Checking Mail"],
            19: ["Dinner Table", "Living Room", "TV Room", "Study", "Netflix", "Family", "Chatting", "Dessert"],
            20: ["Living Room", "Reading", "Relaxing", "Family Time", "Board Game", "Movie", "Sofa", "Popcorn"],
            21: ["Bedroom", "Bathroom", "Lying in Bed", "Reading", "Reading Book", "Kindle", "Washing Face", "Pajamas"],
            22: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Setting Alarm", "Charging Phone", "Lights Out", "Dark Room"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Falling Asleep", "Deep Sleep", "Resting", "Silence", "Recharging"]
        ]
    }
}
