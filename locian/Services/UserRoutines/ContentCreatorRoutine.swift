import Foundation
import Combine

struct ContentCreatorRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Studio", "Home Office", "Editing Desk", "Gaming Setup", "Late Edit", "Rendering", "Uploading", "Discord"],
            1: ["Bedroom", "Lying in Bed", "Late Night Scroll", "Sleeping", "TikTok", "YouTube", "Replying Comments", "Checking Phone"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Recharging", "Silence", "Dark Room", "Pillow"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Dreaming", "Resting", "Stillness", "Comfort", "Blanket"],
            4: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dreaming", "Quiet", "Heavy Sleep", "Peace"],
            5: ["Bedroom", "Lying in Bed", "Waking Up", "Phone", "Notifications", "Checking Analytics", "Subscribers", "Coffee"],
            6: ["Kitchen", "Making Coffee", "Living Room", "Morning Routine", "Vlog Setup", "Camera", "Breakfast", "Thinking Idea"],
            7: ["Home Gym", "Yoga Mat", "Shower", "Kitchen", "Workout", "Taking Selfie", "Outfit", "Getting Ready"],
            8: ["Home Office", "Desk", "Emailing", "Social Media", "Sponsor Deal", "Scripting", "Planning", "Researching Trend"],
            9: ["Studio", "Filming Setup", "Lighting", "Camera", "Mic Check", "Ring Light", "Background", "Action"],
            10: ["Studio", "Recording", "Desk", "Livestream", "Twitch", "Chatting", "Obs", "Playing Game"],
            11: ["Studio", "Desk", "Zoom Call", "Meeting", "Collaborating", "Manager", "Brand", "Pitching"],
            12: ["Kitchen", "Lunch", "Cafe", "Park", "Food Photo", "Posting Story", "Posting", "Fans"],
            13: ["Location Shoot", "City Street", "Event", "Studio", "Vlogging", "B-Roll", "Drone", "Traveling"],
            14: ["Home Office", "Editing", "Computer", "Desk", "Final Cut", "Premiere", "Sound Design", "Thumbnail"],
            15: ["Home Office", "Writing Script", "Planning", "Desk", "Topic", "Hook", "Intro", "Outro"],
            16: ["Studio", "B-Roll", "Product Shots", "Desk", "Unboxing", "Reviewing", "Macro", "Detail"],
            17: ["Event", "Launch Party", "Cafe", "Bar", "Networking", "Collab", "Photos", "Drinks"],
            18: ["Gym", "Walking", "Living Room", "Kitchen", "Sunset", "Relaxing", "Prep Dinner", "Music"],
            19: ["Restaurant", "Eating Dinner", "Kitchen", "Living Room", "Cooking", "Movie", "Netflix", "Couch"],
            20: ["Living Room", "TV", "Editing", "Relaxing", "Using Laptop", "Reviewing", "Polishing", "Uploading"],
            21: ["Living Room", "Social Media", "Bedroom", "Phone", "Engagement", "Comments", "Replying", "Stories"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Reading", "Washing Face", "Lotion", "Pajamas", "Book"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Phone Down", "Silence", "Darkness", "Dreaming"]
        ]
    }
}
