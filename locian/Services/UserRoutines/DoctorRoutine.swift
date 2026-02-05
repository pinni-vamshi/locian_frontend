import Foundation
import Combine

struct DoctorRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Hospital", "On Call Room", "Emergency Room", "Home Bedroom", "Pager Beep", "Vending Machine", "Quiet Hallway", "Nurse Station"],
            1: ["Hospital Ward", "On Call Room", "Emergency Room", "Sleeping", "Bunk Bed", "Reading Light", "Checking Phone", "Lying Down"],
            2: ["On Call Room", "Hospital Ward", "Emergency Desk", "Sleeping", "Deep Sleep", "Napping", "Dark Room", "Resting"],
            3: ["Quiet Ward", "Nursestation", "On Call Room", "Sleeping", "Monitor Beep", "Checking Chart", "Coffee Pot", "Nap in Chair"],
            4: ["On Call Room", "Quiet Ward", "Sleeping", "Emergency Room", "Alarm Ringing", "Putting on Scrubs", "Putting on Shoes", "Stethoscope"],
            5: ["Hospital Cafeteria", "Taking Shower", "Bedroom", "Early Rounds", "Locker Room", "Changing Clothes", "Drinking Coffee", "Handover"],
            6: ["Hospital Ward", "Patient Room", "Morning Rounds", "Handover Meeting", "Holding Clipboard", "Team Huddle", "Elevator", "Reviewing Results"],
            7: ["Hospital Ward", "Staff Room", "Clinic Check-in", "Briefing Room", "Computer Terminal", "Writing Script", "Exam Room", "Waiting Area"],
            8: ["Operating Room", "Clinic", "Consultation Room", "Ward", "Scrubbing In", "Wearing Mask", "Anesthesia Machine", "Performing Surgery"],
            9: ["Operating Room", "Patient Examination", "Clinic", "Ward Office", "Dictating", "Viewing X-Ray", "Checking BP", "Examining Patient"],
            10: ["Consultation Room", "Clinic", "Waiting Area", "Nurse Station", "Phone Call", "Writing Referral", "Typing", "Sanitizing Hands"],
            11: ["Hospital Ward", "ICU", "Lab", "X-Ray Room", "MRI Scanner", "Ventilator", "Checking Monitor", "Checking IV"],
            12: ["Hospital Cafeteria", "Doctor's Lounge", "Office", "Quick Bite", "Eating Sandwich", "Eating Salad", "Coffee Break", "Chatting"],
            13: ["Clinic", "Consultation Room", "Follow-up", "Admin Desk", "Reviewing File", "Signing Form", "Emailing", "Scheduling"],
            14: ["Clinic", "Operating Room", "Recovery Room", "Office", "Post-Op Check", "Checking Vitals", "Discharge Note", "Family Meeting"],
            15: ["Patient Room", "Ward Rounds", "Discharge Meeting", "Office", "Social Worker", "Pharmacy", "Writing Script", "Handshake"],
            16: ["Office", "Doing Paperwork", "Meeting Room", "Consultation", "Researching", "Reading Journal", "Applying Grant", "Zoom Call"],
            17: ["Clinic", "Hospital Exit", "Commuting", "Parking Lot", "Car", "Listening into Radio", "Traffic", "Calling Home"],
            18: ["Gym", "Running Track", "Home", "Living Room", "Wearing Workout Gear", "Treadmill", "Lifting Weights", "Taking Shower"],
            19: ["Kitchen", "Dinner Table", "Restaurant", "Living Room", "Cooking", "Eating Takeout", "Drinking Wine", "Family Chat"],
            20: ["Study", "Home Office", "Reading Journal", "Relaxing", "Using Laptop", "CME Course", "Watching News", "Sofa"],
            21: ["Living Room", "TV Room", "Bedroom", "Sofa", "Streaming Service", "Eating Popcorn", "Under Blanket", "With Partner"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Reading", "Skin Care", "Brushing Teeth", "Pajamas", "Reading Book"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "On Call Alert", "Charging Phone", "Resting", "Darkness", "Falling Asleep"]
        ]
    }
}
