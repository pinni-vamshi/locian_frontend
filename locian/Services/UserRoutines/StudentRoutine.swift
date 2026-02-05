import Foundation
import Combine

struct StudentRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Dorm Room", "Study Desk", "Late Night Cafe", "Common Room", "Buying Snacks", "Gaming Station", "Getting Ready for Bed", "Quiet Corner"],
            1: ["Dorm Room", "Lying in Bed", "Scrolling Phone", "Quiet Lounge", "Eating Late Snack", "Study Desk", "Bathroom", "Walking Hallway"],
            2: ["Bedroom", "Dorm Room", "Sleeping", "Deep Sleep", "Napping", "Staying Up Late", "Quiet Room", "Lying Down"],
            3: ["Bedroom", "Lying in Bed", "Dorm Room", "Deep Sleep", "Sleeping", "Turning Over", "Snoozing", "Late Night"],
            4: ["Bedroom", "Lying in Bed", "Dorm Room", "Deep Sleep", "Waking Up", "Sleeping", "Early Morning", "Cozy Bed"],
            5: ["Bedroom", "Getting Up", "Early Morning Jog", "Gym", "Yoga Corner", "Shower", "Kitchen", "Making Coffee"],
            6: ["Gym", "Dorm Room", "Taking Shower", "Kitchen", "Coffee Shop", "Planning Day", "Packing Bag", "Walking into Bus"],
            7: ["Cafeteria", "Dining Hall", "Bus Stop", "Walkway", "Commuting", "Standing in Line", "Entering Hall", "Lobby"],
            8: ["Classroom", "Lecture Hall", "Lab", "Campus Path", "Locking Bike", "Elevator", "Reading Board", "Sitting at Desk"],
            9: ["Classroom", "Lecture Hall", "Study Hall", "Auditorium", "Taking Notes", "Watching Presentation", "Lab Bench", "Library"],
            10: ["Library", "Study Group Room", "Campus Bench", "Coffee Shop", "Using Laptop", "Quiet Zone", "Printing Paper", "Reading Book"],
            11: ["Classroom", "Seminar Room", "Lab", "Professor's Office", "Chatting in Hallway", "Giving Presentation", "Whiteboard", "Group Table"],
            12: ["Cafeteria", "Food Court", "Campus Lawn", "Student Center", "Using Microwave", "Salad Bar", "Picnic Table", "Vending Area"],
            13: ["Classroom", "Lecture Hall", "Lab", "Workshop", "Studio", "Computer Lab", "Quiet Corner", "Sitting at Desk"],
            14: ["Library", "Quiet Zone", "Computer Lab", "Bookstore", "Study Carrel", "Reference Section", "Charging Station", "Sitting Area"],
            15: ["Gym", "Sports Field", "Recreation Center", "Dorm Room", "Locker Room", "Running Track", "Bleachers", "Equipment Room"],
            16: ["Study Desk", "Library", "Coffee Shop", "Common Room", "Using Laptop", "Group Project", "Writing on Whiteboard", "Highlighting Text"],
            17: ["Dorm Room", "Dining Hall", "Kitchen", "Lounge", "TV Room", "Pantry", "Using Microwave", "Sitting at Table"],
            18: ["Dining Hall", "Cafeteria", "Student Center", "Friend's Room", "Ordering Pizza", "Shared Kitchen", "Lounge Sofa", "Game Room"],
            19: ["Study Desk", "Library", "Lab", "Project Room", "Using Laptop", "Wearing Headphones", "Reading Textbook", "Zoom Call"],
            20: ["Study Desk", "Dorm Room", "Library", "Online Call", "Group Chat", "Desk Lamp", "Taking Notes", "Eating Snack"],
            21: ["Common Room", "Lounge", "Friend's Room", "Dorm Room", "Movie Night", "Eating Popcorn", "Sitting on Sofa", "Walking Hallway"],
            22: ["Dorm Room", "Bedroom", "Bathroom", "Study Desk", "Washing Face", "Changing Clothes", "Charging Phone", "Reading Book"],
            23: ["Bedroom", "Dorm Room", "Lying in Bed", "Late Night Study", "Reading Light", "Scrolling Phone", "Setting Alarm", "Falling Asleep"]
        ]
    }
}
