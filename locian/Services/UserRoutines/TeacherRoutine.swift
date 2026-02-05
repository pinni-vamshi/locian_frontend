import Foundation
import Combine

struct TeacherRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Bedroom", "Home Office", "Grading Papers", "Reading Book", "Quiet House", "Desk Lamp", "Drinking Tea", "Reviewing Grades"],
            1: ["Bedroom", "Lying in Bed", "Reading Book", "Quiet Time", "Sleeping", "Head on Pillow", "Dark Room", "Late Night"],
            2: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Napping", "Under Blanket", "Night Time"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Snoozing", "Comfortable Bed", "Night", "Resting"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Pre-Dawn", "Turning Over", "Sleeping", "Warm Bed"],
            5: ["Kitchen", "Making Coffee", "Bedroom", "Early Prep", "Taking Shower", "Checking Outfit", "Packing Bag", "Drinking Coffee"],
            6: ["Taking Shower", "Kitchen", "Breakfast Nook", "Home Office", "Listening News", "Finding Keys", "Packing Lunch", "Lesson Review"],
            7: ["Commuting", "School Parking Lot", "Classroom", "Staff Room", "Driving Car", "Traffic", "School Gate", "Greeting Guard"],
            8: ["Classroom", "Morning Assembly", "Staff Room", "Hallway", "Taking Attendance", "Ringing Bell", "Student Desk", "Whiteboard"],
            9: ["Classroom", "Giving Lecture", "Whiteboard", "Teacher's Desk", "Projector", "Writing on Board", "Answering Question", "Teaching"],
            10: ["Classroom", "Group Activity", "Staff Room", "Library", "Art Corner", "Reading Nook", "Computer Lab", "Signaling Quiet"],
            11: ["Classroom", "Lab", "Playground", "Meeting Room", "Science Area", "Blowing Whistle", "Teacher's Desk", "Checking Notebooks"],
            12: ["Staff Room", "Cafeteria", "Lunch Table", "Playground Monitor", "Eating Lunch", "Coffee Refill", "Chatting", "Vending Machine"],
            13: ["Classroom", "Reading Corner", "Quiet Time", "Lesson Planning", "Grading", "Marking Papers", "Using Laptop", "Emailing Parents"],
            14: ["Classroom", "Activity Area", "Art Room", "Computer Lab", "Painting Station", "Gluing", "Keyboard Typing", "Looking at Screen"],
            15: ["Classroom", "Bus Duty", "School Exit", "Staff Meeting", "Holding Clipboard", "Using Walkie Talkie", "Waving Parents", "Car Line"],
            16: ["Staff Room", "Meeting", "Parent Conference", "Classroom", "Filling Forms", "Principal's Office", "Taking Notes", "Handshaking"],
            17: ["Commuting", "Grocery Store", "Gas Station", "Home", "Listening Podcast", "Pushing Cart", "Checkout Line", "Unpacking Groceries"],
            18: ["Home Office", "Kitchen", "Living Room", "Gym", "Yoga Mat", "Lifting Weights", "Drinking Water", "Wiping Sweat"],
            19: ["Dinner Table", "Kitchen", "Living Room", "Family Room", "Cooking Dinner", "Washing Dishes", "Using Remote", "Couch"],
            20: ["Home Office", "Grading Papers", "Lesson Prep", "Study", "Using Laptop", "Printing Papers", "Laminating", "Cutting Paper"],
            21: ["Living Room", "TV Room", "Relaxing", "Sofa", "Drinking Wine", "Watching Netflix", "Under Blanket", "Scrolling Phone"],
            22: ["Bedroom", "Bathroom", "Book Nook", "Lying in Bed", "Applying Cream", "Brushing Teeth", "Changing Clothes", "Reading Novel"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Checking Alarm", "Turning off Lights", "Dark Room", "Falling Asleep"]
        ]
    }
}
