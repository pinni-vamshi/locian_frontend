import Foundation
import Combine

struct EngineerManagerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Home Office", "Bedroom", "Late Reading", "Thinking", "Strategizing", "Writing Notes", "Quiet House", "Lying in Bed"],
            1: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dark Room", "Silence", "Pillow", "Recharging"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Dreaming", "Deep Sleep", "Resting", "Stillness", "Comfort"],
            3: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dreaming", "Quiet", "Heavy Sleep", "Blanket"],
            4: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Early Thoughts", "Planning", "Turning Over", "Dreams"],
            5: ["Gym", "Running Path", "Taking Shower", "Kitchen", "Workout", "Listening Protocol", "Drinking Water", "Drinking Coffee"],
            6: ["Kitchen", "Making Coffee", "Home Office", "Checking News", "Email Triage", "Calendar", "Eating Breakfast", "Wearing Suit"],
            7: ["Commuting", "Driving Car", "Listening Podcast", "Office Parking", "Audiobook", "Traffic", "Mental Prep", "Riding Elevator"],
            8: ["Office Desk", "Email Triage", "Coffee Shop", "Elevator", "Greeting Team", "Checking Slack", "Jira", "Prioritizing"],
            9: ["Meeting Room", "Stand-up", "Office Desk", "Hallway", "Team Huddle", "Blocking", "Updates", "Drinking Coffee"],
            10: ["One-on-One", "Office", "Whiteboard Area", "Zoom Booth", "Giving Feedback", "Career Chat", "Mentoring", "Listening"],
            11: ["Conference Room", "Boardroom", "Office Desk", "Lobby", "Strategizing", "Roadmap", "Budgeting", "Presenting"],
            12: ["Restaurant", "Business Lunch", "Office Kitchen", "Cafe", "Networking", "Interviewing", "Eating Salad", "Drinking Coffee"],
            13: ["Meeting Room", "Technical Review", "Desk", "Phone Booth", "Reviewing Architecture", "Design Doc", "Approving", "Asking Questions"],
            14: ["Office Desk", "Planning", "Team Area", "Quiet Room", "Setting OKRs", "Hiring", "Reading Resumes", "Emailing"],
            15: ["All Hands Area", "Presentation Room", "Lounge", "Desk", "Company Update", "Q&A", "Applause", "Eating Snacks"],
            16: ["Meeting Room", "Wrap Up", "Manager's Office", "Desk", "Action Items", "Summarizing", "Planning Tomorrow", "Packing Bag"],
            17: ["Commuting", "Driving Car", "Grocery Store", "Home", "Phone Call", "Radio", "Decompressing", "Driveway"],
            18: ["Kitchen", "Living Room", "Family Time", "Dinner Prep", "Cooking", "Drinking Wine", "Shoes Off", "Kids"],
            19: ["Dinner Table", "Kitchen", "Living Room", "Garden", "Eating Meal", "Conversation", "Laughing", "Washing Dishes"],
            20: ["Living Room", "Relaxing", "Home Office", "Using Laptop", "Reading", "Industry News", "Blogging", "Sitting on Couch"],
            21: ["Bedroom", "Reading", "TV", "Bathroom", "Book", "Kindle", "Leadership", "Brushing Teeth"],
            22: ["Bedroom", "Lying in Bed", "Planning", "Sleeping", "Reflecting", "Gratitude", "Setting Alarm", "Dark Room"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dreaming", "Silence", "Recharging", "Peace"]
        ]
    }
}
